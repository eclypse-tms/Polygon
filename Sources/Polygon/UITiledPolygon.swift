//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

#if canImport(SwiftUI)

#elseif canImport(UIKit)
import UIKit

/// TiledPolygon is a single view with a bunch of neatly tiled polygons in it.
@IBDesignable
public class UITiledPolygon: UIView, TileablePolygonProtocol {
    
    /// kind of polygon that can be tiled on a euclydian plane
    open var tileablePolygonKind: any TileablePolygonKind = Square() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// the convenience function to fill all the polygons with the same color.
    /// if you want to apply an alternating color pattern, use fillColorPattern instead.
    /// - SeeAlso fillColorPattern(_:)
    @IBInspectable open var fillColor: UIColor = UIColor.systemBlue {
        didSet {
            fillColorPattern.removeAll()
            fillColorPattern.append(fillColor)
            setNeedsDisplay()
        }
    }
    
    /// the color to fill the polygons with. Provide more than 1 color to apply
    /// a color pattern to tiled polygons
    @IBInspectable open var fillColorPattern: [UIColor] = [UIColor.systemBlue] {
        didSet {
            if fillColorPattern.isEmpty {
                fillColorPattern.append(.systemBlue)
            }
            setNeedsDisplay()
        }
    }
    
    /// Rotation angle expressed in degrees (for ex: 45°) or radians (for ex: π/4)
    open var rotationAngle: CommonAngle = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Spacing in between the tiles. default value is 1 point.
    open var _interTileSpacing: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    /// indicates either the size of each polygon or the number of polygons per row.
    /// - SeeAlso: TilablePolygonSize
    open var polygonSize = TileablePolygonSize(fixedWidth: 64) {
        didSet {
            setNeedsDisplay()
        }
    }
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    open func commonInit() {
        self.layer.needsDisplayOnBoundsChange = true
        self.contentMode = .scaleAspectFit
    }
    
    override open func draw(_ rect: CGRect) {
        let canvasSize = rect.size
        
        // we need to figure out how many tiles would fit the given canvas size
        // there are 2 ways to lay out the shapes in any given canvas
        // a. we either have a fixed tile width and we use that to determine how many of those would fit
        // b. we have a target number number that we want to fit in this canvas and we derive the size of the shape based on that
        let numberOfTileableColumns: Int
        let numberOfTileableRows: Int
        let effectiveTileSize: CGSize
        
        if let validNumberOfHorizontalPolygons = polygonSize.horizontalPolygonTarget {
            let deducedSize = deduceMetricsFor(flexiblePolygonSize: polygonSize,
                                               canvasSize: canvasSize,
                                               polygonKind: tileablePolygonKind,
                                               interTileSpacing: _interTileSpacing,
                                               targetNumberOfHorizontallyLaidPolygons: validNumberOfHorizontalPolygons)
            numberOfTileableColumns = deducedSize.numberOfTileableColumns
            numberOfTileableRows = deducedSize.numberOfTileableRows
            effectiveTileSize = deducedSize.effectiveTileSize
        } else {
            let deducedSize = deduceMetricsFor(fixedPolygonSize: polygonSize,
                                            canvasSize: canvasSize,
                                            polygonKind: tileablePolygonKind,
                                            interTileSpacing: _interTileSpacing)
            numberOfTileableColumns = deducedSize.numberOfTileableColumns
            numberOfTileableRows = deducedSize.numberOfTileableRows
            effectiveTileSize = deducedSize.effectiveTileSize
        }
        
        // due to staggering effect, we might need to tile around the edges of the canvas
        // for this reason the lower bound may start at -1
        // and upper bounds end at numberOfTileableColumns + 1
        let rowLowerBound = -1
        let rowUpperBound = numberOfTileableRows + 1
        let columnLowerBound = -1
        let columnUpperBound = numberOfTileableColumns + 1
        
        var colorAssignment = -1
            
            //at this point we determined how many rows and columns we would need to tile
            //now we need to iterate over the rows and columns
        for tileX in columnLowerBound..<columnUpperBound {
            //tileX and tileY follows the same X,Y coordinate pattern in a coordinate space.
            //when tileX is zero, we are referring to the first columnns of shapes
            //when tileY is zero, we are referring to the first row of shapes
            //therefore, when tileX = 2
            for tileY in rowLowerBound..<rowUpperBound {
                
                
                // calculate the layout metrics of each tile
                let layoutMetrics = performLayout(for: tileablePolygonKind,
                                                  tileX: tileX,
                                                  tileY: tileY,
                                                  tileSize: effectiveTileSize,
                                                  interTileSpacing: _interTileSpacing)
                
                let boundingRect = CGRect(origin: CGPoint(x: layoutMetrics.tileXOffset, y: layoutMetrics.tileYOffset), size: effectiveTileSize)
                
                
                // because we always draw an extra polygon around the edges of the screen
                // there will be some instances, where that extra polygon is not needed
                // if those polygons are completely out of bounds, then we can skip drawing them
                let canvasRect = CGRect(origin: .zero, size: canvasSize)
                let isOutOfBounds = !canvasRect.intersects(boundingRect)
                if isOutOfBounds {
                    // there is no intersection, let's bail
                    continue
                } else {
                    colorAssignment += 1
                    
                    // we need to calculate the middle point of our frame
                    // we will use this center as an anchor to draw our polygon
                    let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
                    
                    // the polygon points will be located on a circle - hence the radius calculation
                    // this radius calculation also takes into account the border width which gets
                    // added on the outside of the shape
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _interTileSpacing / 2.0
                    
                    var additionalRotation: CGFloat?
                    switch tileablePolygonKind {
                    case is EquilateralTriangle:
                        if tileX.isOdd() {
                            //we need to reverse the rotation 180 degrees when we are tiling odd columns for
                            //triangles
                            additionalRotation = CommonAngle(radians: layoutMetrics.initialShapeRotation + Double.pi).radians
                        }
                    default:
                        // other shapes do not need additional rotation
                        break
                    }
                    
                    let initialPath = drawInitialPolygonPath(for: tileablePolygonKind,
                                                             centerPoint: centerPoint,
                                                             radius: radius,
                                                             rotationInRadians: additionalRotation)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
                    
                    // because we start tiling -1 column first, we need to adjust the loop counter
                    // so that first visible polygon on the upper left corner is the first color in
                    // our color palette
                    if boundingRect.minY < 0 {
                        colorAssignment -= 1
                    }
                    var colorMod = (colorAssignment % fillColorPattern.count)
                    if colorMod < 0 {
                        colorMod = (fillColorPattern.count + colorMod) % fillColorPattern.count
                    }
                    
                    // apply colors and border
                    fillColorPattern[colorMod].setFill()
                    scaledPolygonPath.fill()
                }
            }
        }
    }
}
#endif
