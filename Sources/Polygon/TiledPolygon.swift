//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct TiledPolygon: View {
    
    public internal (set) var _kind: TilablePolygonKind
    /// kind of polygon that can be tiled on a euclydian plane
    @inlinable public func kind(_ kind: TilablePolygonKind) -> TiledPolygon {
        return TiledPolygon(kind: kind,
                            fillColor: self._fillColor,
                            rotationAngle: self._rotationAngle,
                            borderWidth: self._borderWidth,
                            borderColor: self._borderColor,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: self._flexibleTiling)
    }
    
    
    public internal (set) var _fillColor: Color = .blue
    /// the color to fill the polygon with
    @inlinable public func fillColor(_ color: Color) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: color,
                            rotationAngle: self._rotationAngle,
                            borderWidth: self._borderWidth,
                            borderColor: self._borderColor,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: self._flexibleTiling)
    }
    
    public internal (set) var _rotationAngle: Angle = .zero
    
    /// Rotation angle expressed in degrees (45°) or radians (π/4)
    @inlinable public func rotationAngle(_ angle: Angle) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: self._fillColor,
                            rotationAngle: angle,
                            borderWidth: self._borderWidth,
                            borderColor: self._borderColor,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: self._flexibleTiling)
    }
    
    
    public internal (set) var _borderWidth: CGFloat = 1.0
    
    /// optional border width. specify zero to negate the border
    @inlinable public func borderWidth(_ width: CGFloat) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: self._fillColor,
                            rotationAngle: self._rotationAngle,
                            borderWidth: width,
                            borderColor: self._borderColor,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: self._flexibleTiling)
    }
    
    public internal (set) var _borderColor: Color = .black
    
    /// optional border color. only works when the border width is greater than 0
    @inlinable public func borderColor(_ color: Color) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: self._fillColor,
                            rotationAngle: self._rotationAngle,
                            borderWidth: self._borderWidth,
                            borderColor: color,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: self._flexibleTiling)
    }
    
    public internal (set) var _fixedTileSize = CGSize(width: 64, height: 64)
    
    /// setting the fixed tile size remove the previous Tiling option
    @inlinable public func fixedTileSize(_ size: CGSize) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: self._fillColor,
                            rotationAngle: self._rotationAngle,
                            borderWidth: self._borderWidth,
                            borderColor: self._borderColor,
                            fixedTileSize: size,
                            flexibleTiling: self._flexibleTiling)
    }
    
    public internal (set) var _flexibleTiling: FlexibleTiling?
    
    /// setting the flexible tiling parameters override the fixed tile size
    @inlinable public func flexibleTiling(_ flexibleTiling: FlexibleTiling) -> TiledPolygon {
        return TiledPolygon(kind: self._kind,
                            fillColor: self._fillColor,
                            rotationAngle: self._rotationAngle,
                            borderWidth: self._borderWidth,
                            borderColor: self._borderColor,
                            fixedTileSize: self._fixedTileSize,
                            flexibleTiling: flexibleTiling)
    }
    
    private var _originOffset = CGPoint(x: 0, y: 0)
        
    public init(kind: TilablePolygonKind = .square,
                fillColor: Color = .blue,
                rotationAngle: Angle = .zero,
                borderWidth: CGFloat = 1.0,
                borderColor: Color = .black,
                fixedTileSize: CGSize = .init(width: 64, height: 64),
                flexibleTiling: FlexibleTiling? = nil) {
        self._borderWidth = borderWidth
        self._borderColor = borderColor
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
                numberOfHorizontalTiles = Int(validFlexibleTiling.numberOfHorizontalTiles.rounded(.up))
                let canvasSizeAfterInterTilingGapIsApplied = canvasSize.width - (CGFloat(numberOfHorizontalTiles - 1) * validFlexibleTiling.interTilingSpace)
                let widthOfEachTile = canvasSizeAfterInterTilingGapIsApplied / CGFloat(validFlexibleTiling.numberOfHorizontalTiles)
                let heightOfEachTile = widthOfEachTile
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
                    
                    let tileXOffset: CGFloat
                    let tileYOffset: CGFloat
                    if let validFlexibleTiling = _flexibleTiling {
                        tileXOffset = CGFloat(eachLine) * (effectiveTileSize.width + validFlexibleTiling.interTilingSpace)
                        tileYOffset = CGFloat(eachColumn) * (effectiveTileSize.height + validFlexibleTiling.interTilingSpace)
                    } else {
                        tileXOffset = CGFloat(eachLine) * effectiveTileSize.width
                        tileYOffset = CGFloat(eachColumn) * effectiveTileSize.height
                    }
                    
                    let boundingRect = CGRect(origin: CGPoint(x: tileXOffset, y: tileYOffset), size: effectiveTileSize)
                    
                    // we need to calculate the middle point of our frame
                    // we will use this center as an anchor to draw our polygon
                    let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
                    
                    // the polygon points will be located on a circle - hence the radius calculation
                    // this radius calculation also takes into account the border width which gets
                    // added on the outside of the shape
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _borderWidth / 2.0
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    context.stroke(scaledPolygonPath, with: .color(_borderColor), style: StrokeStyle(lineWidth: _borderWidth))
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
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + _borderWidth/2.0)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + _borderWidth/2.0)
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
    let xxx =
    TiledPolygon()
        .kind(.equilateralTriangle)
        .rotationAngle(Angle(degrees: 75))
        .borderWidth(1)
        .borderColor(.black)
        .flexibleTiling(FlexibleTiling(numberOfHorizontalTiles: 4))
        .background(Color.yellow)
        .padding()
    return xxx
}
