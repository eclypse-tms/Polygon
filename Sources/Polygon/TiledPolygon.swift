//
//  TiledPolygon.swift
//
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct TiledPolygon: View {
    /// number of equal sides
    public var numberOfSides: Int = 4 {
        didSet {
            if numberOfSides < 3 {
                numberOfSides = 3
            } else if numberOfSides > 120 {
                numberOfSides = 120
            }
        }
    }
    
    /// the color to fill the polygon with
    public var fillColor: Color = .blue
    
    /// Rotation angle expressed in degrees (45°) or radians (π/4)
    public var rotationAngle: Angle = .zero
    
    /// optional border width. specify zero to negate the border
    public var borderWidth: CGFloat = 1.0
    
    /// optional border color. only works when the border width is greater than 0
    public var borderColor: Color = .black
    
    /// whether to show dashes around the circle that the initial
    /// polygon is rendered before scaling and rotation. used in the
    /// accompanying blog for demonstration purposes.
    public var showDashes: Bool = false
    
    public var fixedTileSize = CGSize(width: 120, height: 120)
    
    public var tiling: Tiling?
    
    public var originOffset = CGPoint(x: 0, y: 0)
        
    public init(numberOfSides: Int = 4,
                fillColor: Color = .blue,
                rotationAngle: Angle = .zero,
                borderWidth: CGFloat = 1.0,
                borderColor: Color = .black,
                tiling: Tiling? = nil,
                showDashes: Bool = false) {
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.showDashes = showDashes
        self.fillColor = fillColor
        self.numberOfSides = numberOfSides
        self.rotationAngle = rotationAngle
        self.tiling = tiling
    }
    
    public init() {}
    
    public var body: some View {
        Canvas { context, canvasSize in
            //first calculate how many tiles would fit the canvas size
            //if we have horizontal/vertical tiling information use that, otherwise,
            //use the fixed tile size instead
            let numberOfHorizontalTiles: Int
            let numberOfVerticalTiles: Int
            let effectiveTileSize: CGSize
            if let validTiling = tiling {
                numberOfHorizontalTiles = Int(validTiling.numberOfHorizontalTiles.rounded(.up))
                let canvasSizeAfterInterTilingGapIsApplied = canvasSize.width - (CGFloat(numberOfHorizontalTiles - 1) * validTiling.interTilingSpace)
                let widthOfEachTile = canvasSizeAfterInterTilingGapIsApplied / CGFloat(validTiling.numberOfHorizontalTiles)
                let heightOfEachTile = widthOfEachTile
                numberOfVerticalTiles = Int((canvasSize.height / heightOfEachTile).rounded(.up))
                effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
            } else {
                numberOfHorizontalTiles = Int((canvasSize.width / fixedTileSize.width).rounded(.up))
                numberOfVerticalTiles = Int((canvasSize.height / fixedTileSize.height).rounded(.up))
                effectiveTileSize = fixedTileSize
            }
            
            //at this point we determined how many rows and columns we would need to tile
             
            
            for eachLine in 0..<numberOfHorizontalTiles {
                //when eachLine is 0, we are tiling the first row on the top
                for eachColumn in 0..<numberOfVerticalTiles {
                    //when eachColumn is 0, we are tiling the first column on the top
                    
                    let tileXOffset: CGFloat
                    let tileYOffset: CGFloat
                    if let validTiling = tiling {
                        tileXOffset = CGFloat(eachLine) * (effectiveTileSize.width + validTiling.interTilingSpace)
                        tileYOffset = CGFloat(eachColumn) * (effectiveTileSize.height + validTiling.interTilingSpace)
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
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    context.stroke(scaledPolygonPath, with: .color(borderColor), style: StrokeStyle(lineWidth: borderWidth))
                    context.fill(scaledPolygonPath, with: .color(fillColor))
                }
            }
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    private func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> Path {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = Path()
        for i in 0..<numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + rotationAngle.radians
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
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + borderWidth)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + borderWidth)
        let finalScaleFactor = min(scaleFactorX, scaleFactorY)
        
        if abs(finalScaleFactor - 1.0) < 0.001 {
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
    let lightGray = Color(white: 0.85)
    let tiledPolygon = TiledPolygon(numberOfSides: 4,
                                    fillColor: .blue,
                                    rotationAngle: Angle(degrees: 45),
                                    borderWidth: 1,
                                    borderColor: .black,
                                    tiling: Tiling(numberOfHorizontalTiles: 7, interTilingSpace: 0))
        .background(lightGray)
        .padding()
    return tiledPolygon
}
