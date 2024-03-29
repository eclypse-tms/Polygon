//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// TiledPolygon is a single view with a bunch of neatly tiled polygons in it.
public struct TiledPolygon: View, TileablePolygonProtocol, DrawTileablePolygon {
    
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
    internal var _interTileSpacing: CGFloat = 2.0
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
    internal var _staggerEffect = StaggerEffect.zero
    
    /// Optional. Provide a positive stagger effect value between 0 and 1 to tile the shapes
    /// with that specified amount of offset on their Y axis
    ///
    /// The provided value is interpreted in terms of percentage of the calculated tile height.
    /// Any values outside of the acceptable range are ignored.
    ///
    /// For example: provide 0.5 for an alternate tiling effect.
    /// ![Squares are tiled in an alternate fashion](https://i.imgur.com/gZm9o4J.png "alternate tiling")
    /// - SeeAlso: TilablePolygonSize
    @inlinable public func staggerEffect(_ effect: StaggerEffect) -> TiledPolygon {
        var newCopy = self
        newCopy._staggerEffect = effect
        return newCopy
    }
        
    public init() {}
        
    public var body: some View {
        Canvas { context, canvasSize in
            drawTilesWithParameters(canvasSize: canvasSize,
                                    polygonSize: _polygonSize,
                                    kind: _kind,
                                    interTileSpacing: _interTileSpacing,
                                    staggerEffect: _staggerEffect,
                                    numberOfColorsInPalette: _fillColorPattern.count,
                                    drawingInstructions: { (patternColorIndex, polygonPath) in
                context.fill(polygonPath.path, with: .color(_fillColorPattern[patternColorIndex]))
            })
        }
    }
}

#Preview {
    let backgroundColor = Color(white: 0.85) //light gray

    // configure the polygon
    let tiledPolygon = TiledPolygon()
        .kind(Hexagon())
        .interTileSpacing(1)
        .staggerEffect(StaggerEffect(0.0))
        .fillColorPattern(Color.viridisPalette)
        .polygonSize(TileablePolygonSize(horizontalPolygonTarget: 21))
        .background(backgroundColor)
        .padding(0)
    
    return tiledPolygon
}
