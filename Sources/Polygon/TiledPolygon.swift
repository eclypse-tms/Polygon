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
    internal var _kind: any TilablePolygonKind = Square()
    /// kind of polygon that can be tiled on a euclydian plane
    @inlinable public func kind(_ kind: TilablePolygonKind) -> TiledPolygon {
        var newCopy = self
        newCopy._kind = kind
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
    internal var _polygonSize = TilablePolygonSize(fixedWidth: 64)
    
    /// indicates either the size of each polygon or the number of polygons per row.
    /// - SeeAlso: TilablePolygonSize
    @inlinable public func polygonSize(_ size: TilablePolygonSize) -> TiledPolygon {
        var newCopy = self
        newCopy._polygonSize = size
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
                // user provided the number of polygon that should be tiled horizontally
                // therefore, leaving the size of each polygon flexible
                numberOfTileableColumns = Int(validNumberOfHorizontalPolygons.rounded(.up))
                
                // this is the left over width once the inter tile space is subtracted from the canvas
                // it is calculated differently depending on the shape of the polygon
                // for example, if _numberOfHorizontallyTiledPolygons is 10, then you will 9 inter-tiling
                // gaps you have to fill for squares and hexagons
                // on the other hand, if you are tiling triangles, the number of spaces will be 5 because
                // when you are tiling triangles, the next triangle is tiled upside-down.
                let canvasWidthAfterInterTilingGapIsApplied: CGFloat
                switch _kind {
                case is EquilateralTriangle:
                    canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * _interTileSpacing)) + (CGFloat(numberOfTileableColumns) / 2.0)
                case is Square, is Hexagon:
                    canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * _interTileSpacing))
                default:
                    canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * _interTileSpacing))
                }
                
                let widthOfEachTile: CGFloat
                let heightOfEachTile: CGFloat
                
                switch _kind {
                case is EquilateralTriangle:
                    // because tiled triangles are STAGGERED, the width of tiled triangles
                    // depend on how many there are. for example: 
                    // if you tile 3 triangles side by side, then width of each triangle is (screen width - 1) / 2
                    // if you tile 4 triangles side by side, then width of each triangle is (screen width - 2) / 2.5
                    // if you tile 5 triangles side by side, then width of each triangle is (screen width - 2) / 3
                    // therefore, the width of each tile is (screen width - (number of triangles / 2).roundDown()) / ((number of triangles / 2) + 0.5)
                    let halfOfHorizontalPolygons = (validNumberOfHorizontalPolygons / 2.0).rounded(.down)
                    let halfOfHorizontalPolygons2 = ((validNumberOfHorizontalPolygons / 2.0) + 0.5)
                    widthOfEachTile = (canvasWidthAfterInterTilingGapIsApplied - halfOfHorizontalPolygons) / halfOfHorizontalPolygons2
                    
                    // because this is a triangle, in order to have a fitting frame, we need to calculate 
                    // the fitting height for the given width.
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: (60)).radians)
                    
                case is Square:
                    widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / validNumberOfHorizontalPolygons
                    heightOfEachTile = widthOfEachTile
                case is Hexagon:
                    // because tiled hexagons are STAGGERED, each hexagon takes 75 % of the space
                    // that a square would have taken. 75 % figure can be calculted by trigonometry.
                    // for this reason, we need to account for this in this in our calculations
                    // space the hexagons accordingly
                    // formula (after simplification) ->
                    widthOfEachTile = (4 * canvasWidthAfterInterTilingGapIsApplied)/(3 * validNumberOfHorizontalPolygons + 1)  //((canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling) * (4/3))
                    
                    // because this is a hexagon, height of each tile is square root 3 x of width
                    heightOfEachTile = widthOfEachTile * sin(Angle(degrees: 60).radians)
                default:
                    widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / validNumberOfHorizontalPolygons
                    heightOfEachTile = widthOfEachTile
                }
                 
                numberOfTileableRows = Int((canvasSize.height / heightOfEachTile).rounded(.up))
                effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
            } else {
                // user provided fixed polygon width; therefore, we need to figure out how many
                // of them will fit in one row.
                let fixedPolygonWidth = _polygonSize.fixedWidth
                switch _kind {
                case is EquilateralTriangle:
                    // when we are tiling triangles, even numbered triangles point up and odd numbered
                    // triangles point down to take up all the available space.
                    // for this reason, we can fit 2 triangles for each tile width
                    let approximateTileWidth = (fixedPolygonWidth * 0.5) + _interTileSpacing
                    
                    numberOfTileableColumns = Int((canvasSize.width / approximateTileWidth).rounded(.up))
                    
                    numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
                    let tightFittingTileHeight = fixedPolygonWidth * sin(Angle(degrees: 60).radians)
                    effectiveTileSize = CGSize(width: fixedPolygonWidth, height: tightFittingTileHeight)
                case is Square:
                    numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
                    numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
                    effectiveTileSize = CGSize(width: fixedPolygonWidth, height: fixedPolygonWidth)
                case is Hexagon:
                    
                    // when we have a fixed tile size each hexagon will take 75% of the provided width
                    // due to hexagon staggering. plus the inter tiling space
                    let approximateTileWidth = (fixedPolygonWidth * 0.75) + _interTileSpacing
                    numberOfTileableColumns = Int((canvasSize.width / approximateTileWidth).rounded(.up))
                    
                    let tightFittingTileHeight = fixedPolygonWidth * sin(Angle(degrees: 60).radians)
                    numberOfTileableRows = Int(tightFittingTileHeight.rounded(.up))
                    effectiveTileSize = CGSize(width: fixedPolygonWidth, height: tightFittingTileHeight)
                default:
                    numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
                    numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
                    effectiveTileSize = CGSize(width: fixedPolygonWidth, height: fixedPolygonWidth)
                }
            }
            
            // triangles and hexagons require additional tiling around the edges
            let rowLowerBound: Int
            let rowUpperBound: Int
            let columnLowerBound: Int
            let columnUpperBound: Int
            
            switch _kind {
            case is EquilateralTriangle:
                // requires additional padding for columns only
                rowLowerBound = -1
                rowUpperBound = numberOfTileableRows
                columnLowerBound = -1
                columnUpperBound = numberOfTileableColumns + 1
            case is Square:
                // doesn't require additional padding
                rowLowerBound = 0
                rowUpperBound = numberOfTileableRows
                columnLowerBound = 0
                columnUpperBound = numberOfTileableColumns
            case is Hexagon:
                // we need hexagons in the -1th row and n+1th row to fill in the tiling gaps around the edges
                rowLowerBound = -1
                rowUpperBound = numberOfTileableRows
                
                // we need hexagons in the -1th and n+1th columns to fill in the tiling gaps
                columnLowerBound = -1
                columnUpperBound = numberOfTileableColumns + 1
            default:
                rowLowerBound = 0
                rowUpperBound = numberOfTileableRows
                columnLowerBound = 0
                columnUpperBound = numberOfTileableColumns
            }
            
            let paddingAroundTheEdges = CGFloat(_interTileSpacing / 2.0)
            
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
                    
                    var staggerConstant = CGFloat(0)
                    var initialShapeRotation = Angle.zero
                    
                    switch _kind {
                    case let equilateralTriangle as EquilateralTriangle:
                        staggerConstant = equilateralTriangle.yAxisStagger
                        initialShapeRotation = equilateralTriangle.initialRotation
                        
                        let finalXStaggeringOffset: CGFloat
                        let finalYStaggeringOffset: CGFloat
                        if tileX.isEven() {
                            finalXStaggeringOffset = CGFloat(tileX / 2) * staggerConstant * sin(Angle(degrees: 30).radians / sin(Angle(degrees: 60).radians))
                            finalYStaggeringOffset = (CGFloat(tileX / 2) * staggerConstant)
                        } else {
                            if tileX < 0 {
                                finalXStaggeringOffset = 0 //CGFloat(tileX / 2 - 1) * staggerConstant * sin(Angle(degrees: 30).radians / sin(Angle(degrees: 60).radians))
                                finalYStaggeringOffset = 0 //(CGFloat(tileX / 2 + 1) * -staggerConstant)
                            } else {
                                finalXStaggeringOffset = CGFloat(tileX / 2 + 1) * staggerConstant * sin(Angle(degrees: 30).radians / sin(Angle(degrees: 60).radians))
                                finalYStaggeringOffset = (CGFloat(tileX / 2 + 1) * staggerConstant)
                            }
                        }
                        
                        let primaryXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) + paddingAroundTheEdges
                        let primaryYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                        let xCorrection = CGFloat(tileX) * (effectiveTileSize.width / 2)
                        
                        tileXOffset = primaryXOffset - xCorrection + finalXStaggeringOffset
                        tileYOffset = primaryYOffset + finalYStaggeringOffset
                    case let square as Square:
                        initialShapeRotation = square.initialRotation
                        
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) + paddingAroundTheEdges
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                    case let hexagon as Hexagon:
                        initialShapeRotation = hexagon.initialRotation
                        
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) - (CGFloat(tileX) * (effectiveTileSize.width / 4)) + paddingAroundTheEdges
                        if isProcessingOddColumn {
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + ((effectiveTileSize.height / 2.0) + (paddingAroundTheEdges * 2))
                        } else {
                            //even indexes we will tile them where they normally go
                            tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                        }
                    default:
                        tileXOffset = CGFloat(tileX) * (effectiveTileSize.width + _interTileSpacing) + paddingAroundTheEdges
                        tileYOffset = CGFloat(tileY) * (effectiveTileSize.height + _interTileSpacing) + paddingAroundTheEdges
                    }
                    
                    // out of bounds correction
                    // this happens when the tiling is staggered
                    let boundingRect: CGRect
                    let outOfBoundsCorrectionLimit = canvasSize.height + _interTileSpacing + effectiveTileSize.height
                    if tileYOffset > outOfBoundsCorrectionLimit, staggerConstant > 0.0 {
                        //the offset is so much that we are drawing entirely out of bounds
                        //correct this so that we are in-bounds again from the top, like infinite screen
                        let outOfBoundsCorrection = CGFloat(staggerConstant/2.0 - (canvasSize.height + effectiveTileSize.height))
                        boundingRect = CGRect(origin: CGPoint(x: tileXOffset, y: tileYOffset + outOfBoundsCorrection), size: effectiveTileSize)
                    } else {
                        boundingRect = CGRect(origin: CGPoint(x: tileXOffset, y: tileYOffset), size: effectiveTileSize)
                    }
                    
                    
                    
                    // we need to calculate the middle point of our frame
                    // we will use this center as an anchor to draw our polygon
                    let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
                    
                    // the polygon points will be located on a circle - hence the radius calculation
                    // this radius calculation also takes into account the border width which gets
                    // added on the outside of the shape
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _interTileSpacing / 2.0
                    
                    switch _kind {
                    case is EquilateralTriangle:
                        if isProcessingOddColumn {
                            //we need to reverse the rotation 180 degrees when
                            initialShapeRotation = Angle(radians: initialShapeRotation.radians + Double.pi)
                        }
                    default:
                        // other shapes do not need additional rotation
                        break
                    }
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius, initialRotation: initialShapeRotation)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    context.fill(scaledPolygonPath, with: .color(_fillColor))
                }
            }
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    private func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat, initialRotation: Angle? = nil) -> Path {
        // this is the slice we have to traverse for each side of the polygon
        let numberOfSides: Int
        switch _kind {
        case let shape as EquilateralTriangle:
            numberOfSides = shape.numberOfSides
        case let shape as Square:
            numberOfSides = shape.numberOfSides
        case let shape as Hexagon:
            numberOfSides = shape.numberOfSides
        default:
            numberOfSides = 4
        }
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = Path()
        for i in 0..<numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + _rotationAngle.radians + (initialRotation ?? Angle.zero).radians
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
        .kind(EquilateralTriangle(yAxisStagger: 12))
        .interTileSpacing(2)
        .polygonSize(TilablePolygonSize(fixedWidth: 60))
        .background(backgroundColor)
        .padding(0)
    return tiledPolygon
}
