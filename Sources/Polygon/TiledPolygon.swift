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
        newCopy._numberOfHorizontallyTiledPolygons = nil
        return newCopy
    }
    
    @usableFromInline 
    internal var _numberOfHorizontallyTiledPolygons: CGFloat?
    /// indicates the number of tiles that should be placed horizontally.
    /// this number also dictates how many tiles can be placed vertically
    /// depending on how many you can fit horizontally.
    /// when you set this number, tile size is derived from the available horizontal space.
    @inlinable
    public func numberOfHorizontallyTiledPolygons(_ number: CGFloat) -> TiledPolygon {
        var newCopy = self
        newCopy._numberOfHorizontallyTiledPolygons = number
        return newCopy
    }
    
    private var _originOffset = CGPoint(x: 0, y: 0)
        
    public init() {}
        
    public var body: some View {
        Canvas { context, canvasSize in
            //first calculate how many tiles would fit the canvas size
            //if we have vertical tiling information use that, otherwise,
            //use the fixed tile size instead
            let numberOfVerticalTiles: Int
            let numberOfHorizontalTiles: Int
            let effectiveTileSize: CGSize
            
            if let validNumberOfHorizontalPolygons = _numberOfHorizontallyTiledPolygons {
                //
                numberOfVerticalTiles = Int(validNumberOfHorizontalPolygons.rounded(.up))
                
                // this is the left over width once the inter tile space is subtracted from the canvas
                // it is calculated differently depending on the shape of the polygon
                // for example, if _numberOfHorizontallyTiledPolygons is 10, then you will 9 inter-tiling
                // gaps you have to fill for squares and hexagons
                // on the other hand, if you are tiling triangles, the number of spaces will be 5 because
                // when you are tiling triangles, the next triangle is tiled upside-down.
                let canvasWidthAfterInterTilingGapIsApplied: CGFloat
                switch _kind {
                case .equilateralTriangle:
                    canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfVerticalTiles) * _interTileSpacing)) + (CGFloat(numberOfVerticalTiles) / 2.0)
                case .square, .hexagon:
                    canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfVerticalTiles) * _interTileSpacing))
                }
                
                let widthOfEachTile: CGFloat
                let heightOfEachTile: CGFloat
                
                switch _kind {
                case .equilateralTriangle:
                    // because tiled triangles are STAGGERED, the width of tiled triangles
                    // depend on how many there are. for example: 
                    // if you tile 3 triangles side by side, then width of each triangle is (screen width - 1) / 2
                    // if you tile 4 triangles side by side, then width of each triangle is (screen width - 2) / 2.5
                    // if you tile 5 triangles side by side, then width of each triangle is (screen width - 2) / 3
                    // therefore, the width of each tile is (screen width - (number of triangles / 2).roundDown()) / ((number of triangles / 2) + 0.5)
                    widthOfEachTile = (canvasWidthAfterInterTilingGapIsApplied - (validNumberOfHorizontalPolygons / 2.0).rounded(.down)) / ((validNumberOfHorizontalPolygons / 2) + 0.5)
                    
                    // because this is a triangle, in order to have a fitting frame, we need to calculate 
                    // the fitting height for the given width.
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: (60)).radians)
                    
                case .square:
                    widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / validNumberOfHorizontalPolygons
                    heightOfEachTile = widthOfEachTile
                case .hexagon:
                    // because tiled hexagons are STAGGERED, each hexagon takes 75 % of the space
                    // that a square would have taken. 75 % figure can be calculted by trigonometry.
                    // for this reason, we need to account for this in this in our calculations
                    // space the hexagons accordingly
                    // formula (after simplification) ->
                    widthOfEachTile = (4 * canvasWidthAfterInterTilingGapIsApplied)/(3 * validNumberOfHorizontalPolygons + 1)  //((canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling) * (4/3))
                    
                    // because this is a hexagon, height of each tile is square root 3 x of width
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: 60).radians)
                }
                 
                numberOfHorizontalTiles = Int((canvasSize.height / heightOfEachTile).rounded(.up))
                effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
            } else {
                switch _kind {
                case .equilateralTriangle:
                    numberOfVerticalTiles = Int((canvasSize.width / _fixedTileSize.width).rounded(.up))
                    numberOfHorizontalTiles = Int((canvasSize.height / _fixedTileSize.height).rounded(.up))
                    effectiveTileSize = _fixedTileSize
                case .square:
                    numberOfVerticalTiles = Int((canvasSize.width  / _fixedTileSize.width).rounded(.up))
                    numberOfHorizontalTiles = Int((canvasSize.height / _fixedTileSize.height).rounded(.up))
                    effectiveTileSize = _fixedTileSize
                case .hexagon:
                    
                    // when we have a fixed tile size each hexagon will take 75% of the provided width
                    // due to hexagon staggering. plus the inter tiling space
                    let approximateTileWidth = (_fixedTileSize.width * 0.75) + _interTileSpacing
                    numberOfVerticalTiles = Int((canvasSize.width / approximateTileWidth).rounded(.up))
                    
                    let approximateTileHeight = _fixedTileSize.width * sin(Angle(degrees: 60).radians)
                    numberOfHorizontalTiles = Int(approximateTileHeight.rounded(.up))
                    effectiveTileSize = CGSize(width: _fixedTileSize.width, height: approximateTileHeight)
                }
            }
            
            // triangles and hexagons require additional tiling around the edges
            let rowLowerBound: Int
            let rowUpperBound: Int
            let columnLowerBound: Int
            let columnUpperBound: Int
            
            switch _kind {
            case .equilateralTriangle:
                // requires additional padding for columns only
                rowLowerBound = 0
                rowUpperBound = numberOfHorizontalTiles
                columnLowerBound = -1
                columnUpperBound = numberOfVerticalTiles + 1
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
            
            let paddingAroundTheEdges = (_interTileSpacing / 2.0)
            
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
                    
                    // for triangles and hexagons, we need to performs translation and rotation
                    // for this reason, we need to know whether we are processing the odd column at the moment
                    let isProcessingOddColumn = tileX.isOdd()
                    
                    switch _kind {
                    case .equilateralTriangle:
                        if tileX == 0 {
                            tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) - (CGFloat(tileX) * (effectiveTileSize.width / 2)) + paddingAroundTheEdges
                        } else {
                            tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) - (CGFloat(tileX) * (effectiveTileSize.width / 2)) + paddingAroundTheEdges
                        }
                        
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                    case .square:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) + paddingAroundTheEdges
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                    case .hexagon:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) - (CGFloat(tileX) * (effectiveTileSize.width / 4)) + paddingAroundTheEdges
                        if isProcessingOddColumn {
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + ((effectiveTileSize.height / 2.0) + (paddingAroundTheEdges * 2))
                        } else {
                            //even indexes we will tile them where they normally go
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
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
                    
                    var rotation: Angle?
                    switch _kind {
                    case .equilateralTriangle:
                        if isProcessingOddColumn {
                            rotation = Angle(radians: .pi)
                        }
                    default:
                        // other shapes do not need additional rotation
                        break
                    }
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius, additionalRotation: rotation)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    context.fill(scaledPolygonPath, with: .color(_fillColor))
                }
            }
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    private func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat, additionalRotation: Angle? = nil) -> Path {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(_kind.numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = Path()
        for i in 0..<_kind.numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + _rotationAngle.radians + (additionalRotation ?? Angle.zero).radians
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
        .kind(.equilateralTriangle)
        .interTileSpacing(1)
        .fixedTileSize(CGSize(width: 54, height: 25))
        //.numberOfHorizontallyTiledPolygons(31)
        .background(backgroundColor)
        .padding()
    return tiledPolygon
}
