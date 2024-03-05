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
    internal var _kind: TilablePolygonKind
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
        
    public init(kind: TilablePolygonKind = .square,
                fillColor: Color = .blue,
                rotationAngle: Angle = .zero,
                interTileSpacing: CGFloat = 1.0,
                fixedTileSize: CGSize = .init(width: 64, height: 64),
                flexibleTiling: CGFloat? = nil) {
        self._interTileSpacing = interTileSpacing
        self._fillColor = fillColor
        self._kind = kind
        self._rotationAngle = rotationAngle
        self._flexibleTiling = flexibleTiling
    }
        
    public var body: some View {
        Canvas { context, canvasSize in
            //first calculate how many tiles would fit the canvas size
            //if we have horizontal/vertical tiling information use that, otherwise,
            //use the fixed tile size instead
            let numberOfHorizontalTiles: Int
            let numberOfVerticalTiles: Int
            let effectiveTileSize: CGSize
            if let validFlexibleTiling = _flexibleTiling {
                numberOfHorizontalTiles = Int(validFlexibleTiling.rounded(.up))
                let canvasSizeAfterInterTilingGapIsApplied = canvasSize.width - (CGFloat(numberOfHorizontalTiles - 1) * _interTileSpacing)
                let widthOfEachTile = canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling
                let heightOfEachTile: CGFloat
                
                switch _kind {
                case .equilateralTriangle:
                    let angle = Angle(degrees: (90 - _rotationAngle.degrees)).radians
                    heightOfEachTile = widthOfEachTile * sin(angle)
                case .square:
                    heightOfEachTile = widthOfEachTile
                case .hexagon:
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: 60).radians)
                }
                 
                numberOfVerticalTiles = Int((canvasSize.height / heightOfEachTile).rounded(.up))
                effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
            } else {
                numberOfHorizontalTiles = Int((canvasSize.width / _fixedTileSize.width).rounded(.up))
                numberOfVerticalTiles = Int((canvasSize.height / _fixedTileSize.height).rounded(.up))
                effectiveTileSize = _fixedTileSize
            }
            
            //at this point we determined how many rows and columns we would need to tile
             
            
            for eachLine in 0..<numberOfHorizontalTiles {
                //when eachLine is 0, we are tiling the first row on the top
                for eachColumn in 0..<numberOfVerticalTiles {
                    //when eachColumn is 0, we are tiling the first column on the top
                    
                    let tileXOffset =  CGFloat(eachLine) * (effectiveTileSize.width + _interTileSpacing)
                    let tileYOffset = CGFloat(eachColumn) * (effectiveTileSize.height + _interTileSpacing)
                    
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
    let xxx =
    TiledPolygon()
        .kind(.equilateralTriangle)
        .interTileSpacing(2)
        .flexibleTiling(4)
        .background(backgroundColor)
        .padding()
    return xxx
}
