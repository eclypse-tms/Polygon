//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// TiledPolygon is a single view with a bunch of neatly tiled polygons in it.
public struct TiledPolygon: View, TileablePolygonProtocol {
    
    @usableFromInline 
    internal var _kind: any TileablePolygonKind = Square()
    /// kind of polygon that can be tiled on a euclydian plane
    @inlinable public func kind(_ kind: any TileablePolygonKind) -> TiledPolygon {
        var newCopy = self
        newCopy._kind = kind
        return newCopy
    }
    
    
    /// the convenience function to fill all the polygons with the same color.
    /// if you want to apply an alternating color pattern, use fillColorPattern instead.
    /// - SeeAlso fillColorPattern(_:)
    @inlinable public func fillColor(_ color: Color) -> TiledPolygon {
        var newCopy = self
        newCopy._fillColorPattern.removeAll()
        newCopy._fillColorPattern.append(color)
        return newCopy
    }

    
    
    @usableFromInline
    internal var _fillColorPattern: [Color] = [.blue]
    /// the color to fill the polygons with. Provide more than 1 color to apply
    /// a color pattern to tiled polygons
    @inlinable public func fillColorPattern(_ pattern: [Color]) -> TiledPolygon {
        var newCopy = self
        if pattern.isEmpty {
            newCopy._fillColorPattern = [.blue]
        } else {
            newCopy._fillColorPattern = pattern
        }
        return newCopy
    }
    
    
    @usableFromInline
    internal var _rotationAngle: Angle = .zero
    /// Rotation angle expressed in degrees (for ex: 45°) or radians (for ex: π/4)
    @inlinable public func rotationAngle(_ angle: Angle) -> TiledPolygon {
        var newCopy = self
        newCopy._rotationAngle = angle
        return newCopy
    }
    
    
    @usableFromInline 
    internal var _interTileSpacing: CGFloat = 1.0
    /// Spacing in between the tiles. default value is 1 point.
    @inlinable public func interTileSpacing(_ spacing: CGFloat) -> TiledPolygon {
        var newCopy = self
        newCopy._interTileSpacing = spacing
        return newCopy
    }
    
    @usableFromInline 
    internal var _polygonSize = TileablePolygonSize(fixedWidth: 64)
    
    /// indicates either the size of each polygon or the number of polygons per row.
    /// - SeeAlso: TilablePolygonSize
    @inlinable public func polygonSize(_ size: TileablePolygonSize) -> TiledPolygon {
        var newCopy = self
        newCopy._polygonSize = size
        return newCopy
    }
    
    @usableFromInline
    internal var _yAxisStaggerEffect = CGFloat.zero
    
    /// Optional. Provide a positive value between 0 and 1 to stagger the shapes on their Y axis
    /// when tiling them. 
    ///
    /// The provided value is interpreted in terms of percentage of the calculated tile height.
    /// Any values outside of the acceptable range are ignored.
    ///
    /// For example: provide 0.5 for an alternate tiling effect.
    /// ![Squares are tiled in an alternate fashion](https://i.imgur.com/gZm9o4J.png "alternate tiling")
    /// - SeeAlso: TilablePolygonSize
    @inlinable public func yAxisStaggerEffect(_ effect: CGFloat) -> TiledPolygon {
        var newCopy = self
        if effect >= 1.0 {
            newCopy._yAxisStaggerEffect = 0.0
        } else if effect < 0.0 {
            newCopy._yAxisStaggerEffect = 0.0
        } else {
            newCopy._yAxisStaggerEffect = effect
        }
        return newCopy
    }
        
    public init() {}
        
    public var body: some View {
        Canvas { context, canvasSize in
            // we need to figure out how many tiles would fit the given canvas size
            // there are 2 ways to lay out the shapes in any given canvas
            // a. we either have a fixed tile width and we use that to determine how many of those would fit
            // b. we have a target number number that we want to fit in this canvas and we derive the size of the shape based on that
            let numberOfTileableColumns: Int
            let numberOfTileableRows: Int
            let effectiveTileSize: CGSize
            
            if let validNumberOfHorizontalPolygons = _polygonSize.horizontalPolygonTarget {
                let deducedSize = deduceMetricsFor(flexiblePolygonSize: _polygonSize,
                                                   canvasSize: canvasSize,
                                                   polygonKind: _kind,
                                                   interTileSpacing: _interTileSpacing,
                                                   targetNumberOfHorizontallyLaidPolygons: validNumberOfHorizontalPolygons)
                numberOfTileableColumns = deducedSize.numberOfTileableColumns
                numberOfTileableRows = deducedSize.numberOfTileableRows
                effectiveTileSize = deducedSize.effectiveTileSize
            } else {
                let deducedSize = deduceMetricsFor(fixedPolygonSize: _polygonSize,
                                                canvasSize: canvasSize,
                                                polygonKind: _kind,
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
                    let layoutMetrics = performLayout(for: _kind,
                                                      tileX: tileX,
                                                      tileY: tileY,
                                                      tileSize: effectiveTileSize,
                                                      interTileSpacing: _interTileSpacing,
                                                      yAxisStagger: _yAxisStaggerEffect)
                    
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
                        switch _kind {
                        case is EquilateralTriangle:
                            if tileX.isOdd() {
                                //we need to reverse the rotation 180 degrees when we are tiling odd columns for
                                //triangles
                                additionalRotation = CGFloat.pi
                            }
                        default:
                            // other shapes do not need additional rotation
                            break
                        }
                        
                        let initialPath = drawInitialPolygonPath(for: _kind,
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
                        var colorMod = (colorAssignment % _fillColorPattern.count)
                        if colorMod < 0 {
                            colorMod = (_fillColorPattern.count + colorMod) % _fillColorPattern.count
                        }
                        context.fill(scaledPolygonPath, with: .color(_fillColorPattern[colorMod]))
                    }
                }
            }
        }
    }
}

#Preview {
    let backgroundColor = Color(white: 0.85) //light gray

    // configure the polygon
    let tiledPolygon = TiledPolygon()
        .kind(Square())
        .interTileSpacing(6)
        .yAxisStaggerEffect(0.5)
        .fillColorPattern(Color.viridisPalette)
        .polygonSize(TileablePolygonSize(fixedWidth: 92))
        .background(backgroundColor)
        .padding(0)
    
    return tiledPolygon
}
