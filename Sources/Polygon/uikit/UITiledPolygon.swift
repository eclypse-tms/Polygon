//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

#if canImport(UIKit)
import UIKit

/// TiledPolygon is a single view with a bunch of neatly tiled polygons in it.
@IBDesignable
public class UITiledPolygon: UIView, TileablePolygonProtocol, DrawTileablePolygon {
    
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
            setNeedsDisplay()
        }
    }
    
    /// Rotation angle expressed in degrees (45°) or radians (π/4)
    open var rotationAngle: CommonAngle = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// Spacing in between the tiles. default value is 2 points.
    open var interTileSpacing: CGFloat = 2.0 {
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
        
    /// Optional. Provide a positive stagger effect value between 0 and 1 to tile the shapes
    /// with that specified amount of offset on their Y axis
    ///
    /// The provided value is interpreted in terms of percentage of the calculated tile height.
    /// Any values outside of the acceptable range are ignored.
    ///
    /// For example: provide 0.5 for an alternate tiling effect.
    /// ![Squares are tiled in an alternate fashion](https://i.imgur.com/gZm9o4J.png "alternate tiling")
    /// - SeeAlso: TilablePolygonSize
    open var staggerEffect = StaggerEffect.zero {
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
        drawTilesWithParameters(canvasSize: rect.size,
                                polygonSize: polygonSize,
                                kind: tileablePolygonKind,
                                interTileSpacing: interTileSpacing,
                                staggerEffect: staggerEffect,
                                numberOfColorsInPalette: fillColorPattern.count,
                                drawingInstructions: { (patternColorIndex, polygonPath) in
            fillColorPattern[patternColorIndex].setFill()
            polygonPath.asUIBezierPath().fill()
            
        })
    }
}


#endif
