//
//  TileablePolygonProtocol.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/10/24.
//

import Foundation

public protocol TileablePolygonProtocol {
    /// given row and column tiling assignment, calculates the layout metrics (i.e. where it should be laid within the canvas)
    /// - Parameters:
    ///   - tileX: refers to the tiles that are laid out horizontally, like the x dimension
    ///   - tileY: refers to the tiles that are laid out vertically, like the y dimension
    ///   - tileSize: size to use when performing calculations - provide the effective tile size
    /// - Returns: metrics on how to lay this tile within the given canvas. does not apply out of bounds correction
    func performLayout(for polygonKind: TileablePolygonKind, tileX: Int, tileY: Int, tileSize: CGSize, interTileSpacing: CGFloat) -> TilingLayoutMetrics
    
    /// You use this when the request is to layout a fixed number of polygons horizontally.
    /// It determines the size of each tile as well as how many rows of tiles are needed.
    func deduceMetricsFor(flexiblePolygonSize: TileablePolygonSize,
                               canvasSize: CGSize,
                               polygonKind: TileablePolygonKind,
                               interTileSpacing: CGFloat,
                               targetNumberOfHorizontallyLaidPolygons: CGFloat) -> DeducedTilingMetrics
    
    /// You use this when the request is to tile polygons with a fixed size. It determines how many
    /// polygons are needed horizontally and vertically to fit the available canvas.
    func deduceMetricsFor(fixedPolygonSize: TileablePolygonSize,
                       canvasSize: CGSize,
                       polygonKind: TileablePolygonKind,
                       interTileSpacing: CGFloat) -> DeducedTilingMetrics
    
    /// given a center point and radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - polygonKind: one of the polygons that can be tiled.
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    func drawInitialPolygonPath(for polygonKind: TileablePolygonKind,
                                centerPoint: CGPoint,
                                radius: CGFloat,
                                rotationInRadians: CGFloat?) -> BezierPath
        
    /// scales the original path so that at least 2 corners of the polygon touches the edge of the frame
    func scale(originalPath: BezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> BezierPath
}

public extension TileablePolygonProtocol {
    func scale(originalPath: BezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> BezierPath {
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
    
    
    func drawInitialPolygonPath(for polygonKind: TileablePolygonKind,
                                centerPoint: CGPoint,
                                radius: CGFloat,
                                rotationInRadians: CGFloat?) -> BezierPath {
        // this is the slice we have to traverse for each side of the polygon
        let numberOfSides: Int
        switch polygonKind {
        case let shape as EquilateralTriangle:
            numberOfSides = shape.numberOfSides
        case let shape as Square:
            numberOfSides = shape.numberOfSides
        case let shape as Hexagon:
            numberOfSides = shape.numberOfSides
        case let shape as Octagon:
            numberOfSides = shape.numberOfSides
        default:
            numberOfSides = 4
        }
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = BezierPath()
        for i in 0..<numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + polygonKind.initialRotation.radians + (rotationInRadians ?? 0.0)
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
    
    func deduceMetricsFor(fixedPolygonSize: TileablePolygonSize,
                       canvasSize: CGSize,
                       polygonKind: TileablePolygonKind,
                       interTileSpacing: CGFloat) -> DeducedTilingMetrics {
        let numberOfTileableColumns: Int
        let numberOfTileableRows: Int
        let effectiveTileSize: CGSize
        
        // user provided fixed polygon width; therefore, we need to figure out how many
        // of them will fit in one row.
        let fixedPolygonWidth = fixedPolygonSize.fixedWidth
        switch polygonKind {
        case is EquilateralTriangle:
            // when we are tiling triangles, even numbered triangles point up and odd numbered
            // triangles point down to take up all the available space.
            // for this reason, we can fit 2 triangles for each tile width
            let approximateTileWidth = (fixedPolygonWidth * 0.5) + interTileSpacing
            
            numberOfTileableColumns = Int((canvasSize.width / approximateTileWidth).rounded(.up))
            
            numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
            let tightFittingTileHeight = fixedPolygonWidth * sin(CommonAngle(degrees: 60).radians)
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: tightFittingTileHeight)
        case is Square:
            numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
            numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: fixedPolygonWidth)
        case is Hexagon:
            
            // when we have a fixed tile size each hexagon will take 75% of the provided width
            // due to hexagon staggering. plus the inter tiling space
            let approximateTileWidth = (fixedPolygonWidth * 0.75) + interTileSpacing
            numberOfTileableColumns = Int((canvasSize.width / approximateTileWidth).rounded(.up))
            
            let tightFittingTileHeight = fixedPolygonWidth * sin(CommonAngle(degrees: 60).radians)
            numberOfTileableRows = Int(tightFittingTileHeight.rounded(.up))
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: tightFittingTileHeight)
        case is Octagon:
            //regular octagons make a square when tiled
            numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
            numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: fixedPolygonWidth)
        default:
            numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
            numberOfTileableRows = Int((canvasSize.height / fixedPolygonWidth).rounded(.up))
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: fixedPolygonWidth)
        }
        
        return DeducedTilingMetrics(numberOfTileableColumns: numberOfTileableColumns,
                                     numberOfTileableRows: numberOfTileableRows,
                                     effectiveTileSize: effectiveTileSize)
    }
    
    /// You use this when the request is to layout a fixed number of polygons horizontally.
    /// It determines the size of each tile as well as how many rows of tiles are needed.
    func deduceMetricsFor(flexiblePolygonSize: TileablePolygonSize,
                               canvasSize: CGSize,
                               polygonKind: TileablePolygonKind,
                               interTileSpacing: CGFloat,
                               targetNumberOfHorizontallyLaidPolygons: CGFloat) -> DeducedTilingMetrics {
        let numberOfTileableColumns: Int
        let numberOfTileableRows: Int
        let effectiveTileSize: CGSize
        
        // user provided the number of polygon that should be tiled horizontally
        // therefore, leaving the size of each polygon flexible
        numberOfTileableColumns = Int(targetNumberOfHorizontallyLaidPolygons.rounded(.up))
        
        // this is the left over width once the inter tile space is subtracted from the canvas
        // it is calculated differently depending on the shape of the polygon
        // for example, if _numberOfHorizontallyTiledPolygons is 10, then you will 9 inter-tiling
        // gaps you have to fill for squares and hexagons
        // on the other hand, if you are tiling triangles, the number of spaces will be 5 because
        // when you are tiling triangles, the next triangle is tiled upside-down.
        let canvasWidthAfterInterTilingGapIsApplied: CGFloat
        switch polygonKind {
        case is EquilateralTriangle:
            canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * interTileSpacing)) + (CGFloat(numberOfTileableColumns) / 2.0)
        case is Square, is Hexagon, is Octagon:
            canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * interTileSpacing))
        default:
            canvasWidthAfterInterTilingGapIsApplied = canvasSize.width - ((CGFloat(numberOfTileableColumns) * interTileSpacing))
        }
        
        let widthOfEachTile: CGFloat
        let heightOfEachTile: CGFloat
        
        switch polygonKind {
        case is EquilateralTriangle:
            // because tiled triangles are STAGGERED, the width of tiled triangles
            // depend on how many there are. for example:
            // if you tile 3 triangles side by side, then width of each triangle is (screen width - 1) / 2
            // if you tile 4 triangles side by side, then width of each triangle is (screen width - 2) / 2.5
            // if you tile 5 triangles side by side, then width of each triangle is (screen width - 2) / 3
            // therefore, the width of each tile is (screen width - (number of triangles / 2).roundDown()) / ((number of triangles / 2) + 0.5)
            let halfOfHorizontalPolygons = (targetNumberOfHorizontallyLaidPolygons / 2.0).rounded(.down)
            let halfOfHorizontalPolygons2 = ((targetNumberOfHorizontallyLaidPolygons / 2.0) + 0.5)
            widthOfEachTile = (canvasWidthAfterInterTilingGapIsApplied - halfOfHorizontalPolygons) / halfOfHorizontalPolygons2
            
            // because this is a triangle, in order to have a fitting frame, we need to calculate
            // the fitting height for the given width.
            heightOfEachTile = widthOfEachTile * sin(CommonAngle(degrees: (60)).radians)
            
        case is Square, is Octagon:
            widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / targetNumberOfHorizontallyLaidPolygons
            heightOfEachTile = widthOfEachTile
        case is Hexagon:
            // because tiled hexagons are STAGGERED, each hexagon takes 75 % of the space
            // that a square would have taken. 75 % figure can be calculted by trigonometry.
            // for this reason, we need to account for this in this in our calculations
            // space the hexagons accordingly
            // formula (after simplification) ->
            widthOfEachTile = (4 * canvasWidthAfterInterTilingGapIsApplied)/(3 * targetNumberOfHorizontallyLaidPolygons + 1)  //((canvasSizeAfterInterTilingGapIsApplied / validFlexibleTiling) * (4/3))
            
            // because this is a hexagon, height of each tile is square root 3 x of width
            heightOfEachTile = widthOfEachTile * sin(CommonAngle(degrees: 60).radians)
        default:
            widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / targetNumberOfHorizontallyLaidPolygons
            heightOfEachTile = widthOfEachTile
        }
         
        numberOfTileableRows = Int((canvasSize.height / heightOfEachTile).rounded(.up))
        effectiveTileSize = CGSize(width: widthOfEachTile,height: heightOfEachTile)
        
        return DeducedTilingMetrics(numberOfTileableColumns: numberOfTileableColumns,
                                     numberOfTileableRows: numberOfTileableRows,
                                     effectiveTileSize: effectiveTileSize)
    }
    
    func performLayout(for polygonKind: TileablePolygonKind, tileX: Int, tileY: Int, tileSize: CGSize, interTileSpacing: CGFloat) -> TilingLayoutMetrics {
        let tileXOffset: CGFloat
        let tileYOffset: CGFloat
        // apply half of the inter tile spacing around the edges to make it look right
        let paddingAroundTheEdges = CGFloat(interTileSpacing / 2.0)
        
        // for triangles and hexagons, we need to performs translation and rotation
        // for this reason, we need to know whether we are processing the odd column at the moment
        let isProcessingOddColumn = tileX.isOdd()
        
        var appliedStaggerValue = CGFloat(0)
        var initialShapeRotation = CommonAngle.zero
        
        switch polygonKind {
        case let equilateralTriangle as EquilateralTriangle:
            appliedStaggerValue = equilateralTriangle.staggerEffect
            initialShapeRotation = equilateralTriangle.initialRotation
            
            let finalXStaggeringOffset: CGFloat
            let finalYStaggeringOffset: CGFloat
            if tileX.isEven() {
                finalXStaggeringOffset = CGFloat(tileX / 2) * appliedStaggerValue * sin(CommonAngle(degrees: 30).radians / sin(CommonAngle(degrees: 60).radians))
                finalYStaggeringOffset = (CGFloat(tileX / 2) * appliedStaggerValue)
            } else {
                if tileX == -1 {
                    //special case for column -1 // no staggering effect needed
                    finalXStaggeringOffset = 0
                    finalYStaggeringOffset = 0
                } else {
                    finalXStaggeringOffset = CGFloat((tileX / 2) + 1) * appliedStaggerValue * sin(CommonAngle(degrees: 30).radians / sin(CommonAngle(degrees: 60).radians))
                    finalYStaggeringOffset = (CGFloat((tileX / 2) + 1) * appliedStaggerValue)
                }
            }
            
            let primaryXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            let primaryYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
            let xCorrection = CGFloat(tileX) * (tileSize.width / 2)
            
            tileXOffset = primaryXOffset - xCorrection + finalXStaggeringOffset
            tileYOffset = primaryYOffset + finalYStaggeringOffset
        case let aSquare as Square:
            initialShapeRotation = aSquare.initialRotation
            appliedStaggerValue = aSquare.staggerEffect
            let staggerOffsetPerColumn = (CGFloat(tileX) * appliedStaggerValue)
            
            let totalModulus = tileSize.height + interTileSpacing
            let modulatedStaggerOffset = staggerOffsetPerColumn.remainder(dividingBy: totalModulus) - (totalModulus)
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffset
            
        case let aHexagon as Hexagon:
            initialShapeRotation = aHexagon.initialRotation
            appliedStaggerValue = aHexagon.staggerEffect
            
            // because a hexagon's base length is half the width of its enclosing square
            // we need half of that amount in negative offset so that each hexagon fits nicely
            // in a staggered way
            let negativeOffsetNeededForGaplessTiling = aHexagon.baseLength(for: tileSize.width) / 2.0
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing - negativeOffsetNeededForGaplessTiling) + paddingAroundTheEdges
            if isProcessingOddColumn {
                tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + ((tileSize.height / 2.0) + (paddingAroundTheEdges * 2))
            } else {
                //even indexes we will tile them where they normally go
                tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
            }
        case let anOctagon as Octagon:
            initialShapeRotation = anOctagon.initialRotation
            appliedStaggerValue = anOctagon.staggerEffect
            let staggerOffsetPerColumn = (CGFloat(tileX) * appliedStaggerValue)
            
            let totalModulus = tileSize.height + interTileSpacing
            let modulatedStaggerOffset = staggerOffsetPerColumn.remainder(dividingBy: totalModulus) - (totalModulus)
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffset
            /*
            initialShapeRotation = anOctagon.initialRotation
            appliedStaggerValue = anOctagon.staggerEffect
            
            // because a hexagon's base length is half the width of its enclosing square
            // we need half of that amount in negative offset so that each hexagon fits nicely
            // in a staggered way
            let negativeOffsetNeededForGaplessTiling = anOctagon.baseLength(for: tileSize.width) / 2.0
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing - negativeOffsetNeededForGaplessTiling) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
            */
        default:
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
        }
        
        return TilingLayoutMetrics(tileXOffset: tileXOffset,
                                         tileYOffset: tileYOffset,
                                         initialShapeRotation: initialShapeRotation.radians,
                                         appliedStaggerEffect: appliedStaggerValue)
    }
}
