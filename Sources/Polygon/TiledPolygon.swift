//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct TiledPolygon: View {
    
    @usableFromInline 
    internal var _kind: TilablePolygonKind = .square
    /// kind of polygon that can be tiled on a euclydian plane
    @inlinable public func kind(_ kind: TilablePolygonKind) -> TiledPolygon {
        var newCopy = self
        newCopy._kind = kind
        newCopy._rotationAngle = kind.defaultRotation
        return newCopy
    }
    
    
    @usableFromInline
    internal var _fillColor: Color = .blue
    /// the color to fill the polygon with
    @inlinable public func fillColor(_ color: Color) -> TiledPolygon {
        var newCopy = self
        newCopy._fillColor = color
        return newCopy
    }
    
    @usableFromInline
    internal var _rotationAngle: Angle = .zero
    /// Rotation angle expressed in degrees (45°) or radians (π/4)
    @inlinable public func rotationAngle(_ angle: Angle) -> TiledPolygon {
        var newCopy = self
        newCopy._rotationAngle = angle
        return newCopy
    }
    
    
    @usableFromInline 
    internal var _interTileSpacing: CGFloat = 1.0
    /// optional border width. specify zero to negate the border
    @inlinable public func interTileSpacing(_ spacing: CGFloat) -> TiledPolygon {
        var newCopy = self
        newCopy._interTileSpacing = spacing
        return newCopy
    }
    
    @usableFromInline 
    internal var _fixedTileSize = CGSize(width: 64, height: 64)
    /// setting the fixed tile size remove the previous Tiling option
    @inlinable public func fixedTileSize(_ size: CGSize) -> TiledPolygon {
        var newCopy = self
        newCopy._fixedTileSize = size
        newCopy._flexibleTiling = nil
        return newCopy
    }
    
    @usableFromInline 
    internal var _flexibleTiling: CGFloat?
    /// indicates the number of tiles that should be placed horizontally.
    /// this number also dictates how many tiles can be placed vertically
    /// depending on how many you can fit horizontally.
    @inlinable 
    public func flexibleTiling(_ flexibleTiling: CGFloat) -> TiledPolygon {
        var newCopy = self
        newCopy._flexibleTiling = flexibleTiling
        return newCopy
    }
    
    private var _originOffset = CGPoint(x: 0, y: 0)
        
    public init() {}
        
    public var body: some View {
        Canvas { context, canvasSize in
            //first calculate how many tiles would fit the canvas size
            //if we have horizontal/vertical tiling information use that, otherwise,
            //use the fixed tile size instead
            let numberOfVerticalTiles: Int
            let numberOfHorizontalTiles: Int
            let effectiveTileSize: CGSize
            
            if let validFlexibleTiling = _flexibleTiling {
                numberOfVerticalTiles = Int(validFlexibleTiling.rounded(.up))
                let canvasSizeAfterInterTilingGapIsApplied = canvasSize.width - (CGFloat(numberOfVerticalTiles - 1) * _interTileSpacing)
                let widthOfEachTile: CGFloat
                let heightOfEachTile: CGFloat
                
                switch _kind {
                case .equilateralTriangle:
                    widthOfEachTile = canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling
                    let angle = Angle(degrees: (90 - _rotationAngle.degrees)).radians
                    heightOfEachTile = widthOfEachTile * sin(angle)
                    
                case .square:
                    widthOfEachTile = canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling
                    heightOfEachTile = widthOfEachTile
                case .hexagon:
                    // because tiled hexagons are staggered, each hexagon takes 75 % of the space
                    // that a square would have taken. 75 % figure can be calculted by trigonometry.
                    // for this reason, we need to account for this in this calculation
                    // formula (after simplification) ->
                    widthOfEachTile = (4 * canvasSizeAfterInterTilingGapIsApplied)/(3 * validFlexibleTiling + 1)  //((canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling) * (4/3))
                    
                    // because this is a hexagon, height of each tile is square root 3 x of width
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: 60).radians)
                }
                 
                numberOfHorizontalTiles = Int((canvasSize.height / heightOfEachTile).rounded(.up))
                effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
            } else {
                numberOfVerticalTiles = Int((canvasSize.width / _fixedTileSize.width).rounded(.up))
                numberOfHorizontalTiles = Int((canvasSize.height / _fixedTileSize.height).rounded(.up))
                effectiveTileSize = _fixedTileSize
            }
            
            // triangles and hexagons require additional tiling around the edges
            
            let rowLowerBound: Int
            let rowUpperBound: Int
            let columnLowerBound: Int
            let columnUpperBound: Int
            
            switch _kind {
            case .equilateralTriangle:
                // doesn't require additional padding
                rowLowerBound = 0
                rowUpperBound = numberOfHorizontalTiles
                columnLowerBound = 0
                columnUpperBound = numberOfVerticalTiles
            case .square:
                // doesn't require additional padding
                rowLowerBound = 0
                rowUpperBound = numberOfHorizontalTiles
                columnLowerBound = 0
                columnUpperBound = numberOfVerticalTiles
            case .hexagon:
                // we need hexagons in the -1th row and n+1th row to fill in the tiling gaps around the edges
                rowLowerBound = -1
                rowUpperBound = numberOfHorizontalTiles
                
                // we need hexagons in the -1th and n+1th columns to fill in the tiling gaps
                columnLowerBound = -1
                columnUpperBound = numberOfVerticalTiles + 1
            }
            
            
            //at this point we determined how many rows and columns we would need to tile
            //now we need to iterate over the rows and columns
            for tileX in columnLowerBound..<columnUpperBound {
                //tileX and tileY follows the same X,Y coordinate pattern in a coordinate space.
                //when tileX is zero, we are referring to the first columnns of shapes
                //when tileY is zero, we are referring to the first row of shapes
                //therefore, when tileX = 2
                for tileY in rowLowerBound..<rowUpperBound {
                    let tileXOffset: CGFloat
                    let tileYOffset: CGFloat
                    
                    switch _kind {
                    case .equilateralTriangle:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing)
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing)
                    case .square:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing)
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing)
                    case .hexagon:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) - (CGFloat(tileX) * (effectiveTileSize.width / 4))
                        if tileX % 2 == 1 || tileX % 2 == -1 {
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + effectiveTileSize.height / 2
                        } else {
                            //even indexes we will tile them where they normally go
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing)
                        }
                        
                    }
                    
                    
                    let boundingRect = CGRect(origin: CGPoint(x: tileXOffset, y: tileYOffset), size: effectiveTileSize)
                    
                    // we need to calculate the middle point of our frame
                    // we will use this center as an anchor to draw our polygon
                    let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
                    
                    // the polygon points will be located on a circle - hence the radius calculation
                    // this radius calculation also takes into account the border width which gets
                    // added on the outside of the shape
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _interTileSpacing / 2.0
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    context.fill(scaledPolygonPath, with: .color(_fillColor))
                }
            }
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    private func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> Path {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(_kind.numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = Path()
        for i in 0..<_kind.numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + _rotationAngle.radians
            let x = centerPoint.x + radius * cos(rotatedAngleFromCenter)
            let y = centerPoint.y + radius * sin(rotatedAngleFromCenter)
            if i == 0 {
                polygonPath.move(to: CGPoint(x: x, y: y))
            } else {
                polygonPath.addLine(to: CGPoint(x: x, y: y))
            }
        }
        polygonPath.closeSubpath()
        return polygonPath
    }
    
    private func scale(originalPath: Path, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> Path {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = originalPath.boundingRect
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height)
        let finalScaleFactor = min(scaleFactorX, scaleFactorY)
        
        if abs(finalScaleFactor - 1.0) < 0.000001 {
            // either the height or width of the shape is already at it max
            // the shape cannot be scaled any further
            return originalPath
        } else {
            // scale the shape based on the calculated scale factor
            let scaledAffineTransform = CGAffineTransform(scaleX: finalScaleFactor, y: finalScaleFactor)
            let scaledNonCenteredPath = originalPath.transform(scaledAffineTransform).path(in: rect)
            
            if reCenter {
                // scaling operation happens with respect to the origin/anchor point
                // as a result, scaling the polygon will shift its center
                // we need to bring the shape back to the original rectangle's center
                let centerAfterScaling = CGPoint(x: scaledNonCenteredPath.boundingRect.midX, y: scaledNonCenteredPath.boundingRect.midY)
                let recenteredAffineTransfor = CGAffineTransform(translationX: originalCenter.x - centerAfterScaling.x, y: originalCenter.y - centerAfterScaling.y)
                return scaledNonCenteredPath.transform(recenteredAffineTransfor).path(in: rect)
            } else {
                // we don't need to recenter, we are done!
                return scaledNonCenteredPath
            }
        }
    }
}

#Preview {
    let backgroundColor = Color(white: 0.85)
    let tiledPolygon = TiledPolygon()
        .kind(.hexagon)
        .interTileSpacing(2)
        .flexibleTiling(11)
        .background(backgroundColor)
        .padding()
    return tiledPolygon
}
