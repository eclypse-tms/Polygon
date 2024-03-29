//
//  TileablePolygonProtocol.swift
//
//
//  Created by eclypse on 3/10/24.
//

import Foundation
import SwiftUI

public protocol TileablePolygonProtocol: DrawTileablePolygon {
    /// given row and column tiling assignment, calculates the layout metrics (i.e. where it should be laid within the canvas)
    /// - Parameters:
    ///   - tileX: refers to the tiles that are laid out horizontally, like the x dimension
    ///   - tileY: refers to the tiles that are laid out vertically, like the y dimension
    ///   - tileSize: size to use when performing calculations - provide the effective tile size
    ///   - interTileSpacing: space used to separate one tile from the others
    ///   - canvasRect: a rectangle that represents the enclosing canvas
    ///   - staggerEffect: a percent value to stagger tiles on their Y axis when tiling them.
    /// - Returns: metrics on how to lay this tile within the given canvas. does not apply out of bounds correction
    func performLayout(for polygonKind: any TileablePolygonKind, 
                       tileX: Int,
                       tileY: Int,
                       tileSize: CGSize,
                       interTileSpacing: CGFloat,
                       canvasRect: CGRect,
                       staggerEffect: StaggerEffect?) -> TilingLayoutMetrics
    
    /// You use this when the request is to layout a fixed number of polygons horizontally.
    /// It determines the size of each tile as well as how many rows of tiles are needed.
    func deduceMetricsFor(flexiblePolygonSize: TileablePolygonSize,
                          canvasSize: CGSize,
                          polygonKind: any TileablePolygonKind,
                          interTileSpacing: CGFloat,
                          targetNumberOfHorizontallyLaidPolygons: CGFloat) -> DeducedTilingMetrics
    
    /// You use this when the request is to tile polygons with a fixed size. It determines how many
    /// polygons are needed horizontally and vertically to fit the available canvas.
    func deduceMetricsFor(fixedPolygonSize: TileablePolygonSize,
                          canvasSize: CGSize,
                          polygonKind: any TileablePolygonKind,
                          interTileSpacing: CGFloat) -> DeducedTilingMetrics
    
    /// calculates how many tiles could be laid out vertically for a given layout parameters
    /// depending on the parameters we can layout either numberOfAvailableRows or numberOfAvailableRows - 1
    func numberOfFittingTiles(for polygonKind: any TileablePolygonKind,
                              rowRange: Range<Int>,
                              columnIndex: Int,
                              tileSize: CGSize,
                              interTileSpacing: CGFloat,
                              canvasRect: CGRect,
                              staggerEffect: StaggerEffect?) -> Int
    
    func drawTilesWithParameters(canvasSize: CGSize,
                      polygonSize: TileablePolygonSize,
                      kind: any TileablePolygonKind,
                      interTileSpacing: CGFloat,
                      staggerEffect: StaggerEffect,
                      numberOfColorsInPalette: Int,
                      drawingInstructions: (Int, BezierPath) -> Void)
}

public extension TileablePolygonProtocol {
    func drawTilesWithParameters(canvasSize: CGSize,
                      polygonSize: TileablePolygonSize,
                      kind: any TileablePolygonKind,
                      interTileSpacing: CGFloat,
                      staggerEffect: StaggerEffect,
                      numberOfColorsInPalette: Int,
                      drawingInstructions: (Int, BezierPath) -> Void) {
        let canvasRect = CGRect(origin: .zero, size: canvasSize)
        
        // we need to figure out how many tiles would fit the given canvas size
        // there are 2 ways to lay out the shapes in any given canvas
        // a. we either have a fixed tile width and we use that to determine how many of those would fit
        // b. we have a target number number that we want to fit in this canvas and we derive the size of the shape based on that
        let numberOfTileableColumns: Int
        let numberOfTileableRows: Int
        let effectiveTileSize: CGSize
        
        if let validNumberOfHorizontalPolygons = polygonSize.horizontalPolygonTarget {
            let deducedSize = deduceMetricsFor(flexiblePolygonSize: polygonSize,
                                               canvasSize: canvasSize,
                                               polygonKind: kind,
                                               interTileSpacing: interTileSpacing,
                                               targetNumberOfHorizontallyLaidPolygons: validNumberOfHorizontalPolygons)
            numberOfTileableColumns = deducedSize.numberOfTileableColumns
            numberOfTileableRows = deducedSize.numberOfTileableRows
            effectiveTileSize = deducedSize.effectiveTileSize
        } else {
            let deducedSize = deduceMetricsFor(fixedPolygonSize: polygonSize,
                                            canvasSize: canvasSize,
                                            polygonKind: kind,
                                            interTileSpacing: interTileSpacing)
            numberOfTileableColumns = deducedSize.numberOfTileableColumns
            numberOfTileableRows = deducedSize.numberOfTileableRows
            effectiveTileSize = deducedSize.effectiveTileSize
        }
        
        // due to staggering effect, we might need to tile around the edges of the canvas
        // for this reason the lower bound may start at -1
        // and upper bounds end at numberOfTileableColumns + 1
        let rowLowerBound = -1
        let rowUpperBound = numberOfTileableRows
        let columnLowerBound = -1
        let columnUpperBound = numberOfTileableColumns + 1
        
        var colorAssignment = -1
        var minusColumnTileCounter = -1
        
        let numberOfTilesInMinus1Column = numberOfFittingTiles(for: kind,
                             rowRange: rowLowerBound..<rowUpperBound,
                             columnIndex: -1,
                             tileSize: effectiveTileSize,
                             interTileSpacing: interTileSpacing,
                             canvasRect: canvasRect,
                             staggerEffect: staggerEffect)
        
        
        //at this point we determined how many rows and columns we would need to tile
        //now we need to iterate over the rows and columns
        for tileX in columnLowerBound..<columnUpperBound {
            //tileX and tileY follows the same X,Y coordinate pattern in a coordinate space.
            //when tileX is zero, we are referring to the first columnns of shapes
            //when tileY is zero, we are referring to the first row of shapes
            //therefore, when tileX = 2
            for tileY in rowLowerBound..<rowUpperBound {
                
                
                // calculate the layout metrics of each tile
                let layoutMetrics = performLayout(for: kind,
                                                  tileX: tileX,
                                                  tileY: tileY,
                                                  tileSize: effectiveTileSize,
                                                  interTileSpacing: interTileSpacing,
                                                  canvasRect: canvasRect,
                                                  staggerEffect: staggerEffect)
                
                // print("tileX: \(tileX), tileY: \(tileY), x: \(boundingRect.origin.x.roundX), y: \(boundingRect.origin.y.roundX), width: \(boundingRect.width.roundX), height: \(boundingRect.height.roundX), isOutOfBounds: \(isOutOfBounds)")
                if layoutMetrics.isOutOfBounds {
                    continue
                } else {
                    var totalRotation = kind.initialRotation.radians
                    switch kind {
                    case is EquilateralTriangle:
                        if tileX.isOdd() {
                            //we need to reverse the rotation 180 degrees when we are tiling odd columns for
                            //triangles
                            totalRotation += CGFloat.pi
                        }
                    default:
                        // other shapes do not need additional rotation
                        break
                    }
                    
                    let initialPath = drawPolygonPath(kind: kind,
                                                      boundingRect: layoutMetrics.boundingRect,
                                                      centerPoint: layoutMetrics.centerPoint,
                                                      radius: layoutMetrics.radius,
                                                      rotationInRadians: totalRotation)
                    
                    let finalPath = scale(originalPath: initialPath,
                                          rect: layoutMetrics.boundingRect,
                                          originalCenter: layoutMetrics.centerPoint,
                                          reCenter: true,
                                          borderWidth: nil)
                    
                    var colorMod: Int
                    if tileX < 0 {
                        minusColumnTileCounter += 1
                        let outOfBoundTilesColorAssignment = numberOfColorsInPalette - numberOfTilesInMinus1Column + minusColumnTileCounter
                        
                        colorMod = outOfBoundTilesColorAssignment % numberOfColorsInPalette
                        print("tileX: \(tileX), tileY: \(tileY), numberOfTileableRows: \(numberOfTileableRows), colorAssignment: \(outOfBoundTilesColorAssignment), colorMod: \(colorMod)")
                    } else {
                        colorAssignment += 1
                        colorMod = (colorAssignment % numberOfColorsInPalette)
                    }
                    
                    // because we start tiling -1 column first, we need to adjust the loop counter
                    // so that first visible polygon on the upper left corner is the first color in
                    // our color palette
                    
                    if colorMod < 0 {
                        colorMod = (numberOfColorsInPalette + colorMod) % numberOfColorsInPalette
                    }
                    
                    drawingInstructions(colorMod, finalPath)
                }
            }
        }
    }
    
    func deduceMetricsFor(fixedPolygonSize: TileablePolygonSize,
                       canvasSize: CGSize,
                       polygonKind: any TileablePolygonKind,
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
        case let aRectangle as Quadgon:
            let rectangleHeight = fixedPolygonWidth / aRectangle.widthToHeightRatio
            numberOfTileableColumns = Int((canvasSize.width  / fixedPolygonWidth).rounded(.up))
            numberOfTileableRows = Int((canvasSize.height / rectangleHeight).rounded(.up))
            effectiveTileSize = CGSize(width: fixedPolygonWidth, height: rectangleHeight)
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
                               polygonKind: any TileablePolygonKind,
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
        case is Square, is Hexagon, is Octagon, is Quadgon:
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
        case let aRect as Quadgon:
            widthOfEachTile = canvasWidthAfterInterTilingGapIsApplied / targetNumberOfHorizontallyLaidPolygons
            heightOfEachTile = widthOfEachTile / aRect.widthToHeightRatio
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
    
    func numberOfFittingTiles(for polygonKind: any TileablePolygonKind,
                              rowRange: Range<Int>,
                              columnIndex: Int,
                              tileSize: CGSize,
                              interTileSpacing: CGFloat,
                              canvasRect: CGRect,
                              staggerEffect: StaggerEffect?) -> Int {
        //at this point we determined how many rows and columns we would need to tile
        //now we need to iterate over the rows and columns
        var numberOfInBoundTiles = 0
        
        let tileX = columnIndex
        for tileY in rowRange {
            let layoutResult = performLayout(for: polygonKind,
                     tileX: tileX,
                     tileY: tileY,
                     tileSize: tileSize,
                     interTileSpacing: interTileSpacing,
                     canvasRect: canvasRect,
                     staggerEffect: staggerEffect)
            if !layoutResult.isOutOfBounds {
                numberOfInBoundTiles += 1
            }
        }
        
        return numberOfInBoundTiles
    }
    
    func performLayout(for polygonKind: any TileablePolygonKind, 
                       tileX: Int,
                       tileY: Int,
                       tileSize: CGSize,
                       interTileSpacing: CGFloat,
                       canvasRect: CGRect,
                       staggerEffect: StaggerEffect?) -> TilingLayoutMetrics {
        let tileXOffset: CGFloat
        let tileYOffset: CGFloat
        // apply half of the inter tile spacing around the edges to make it look right
        let paddingAroundTheEdges = CGFloat(interTileSpacing / 2.0)
        
        // provided stagger effect is either the one passed by the user or zero
        let providedStaggerEffect = staggerEffect ?? .zero
        
        // for triangles and hexagons, we need to performs translation and rotation
        // for this reason, we need to know whether we are processing the odd column at the moment
        let isProcessingOddColumn = tileX.isOdd()
        
        // applied stagger effect depends whether requested axis is X or Y
        var appliedstaggerEffectValue: CGFloat
        switch providedStaggerEffect.axis {
        case .yAxis:
            appliedstaggerEffectValue = (providedStaggerEffect.amount) * (tileSize.height + interTileSpacing)
        }
        var initialShapeRotation = CommonAngle.zero
        
        switch polygonKind {
        case let equilateralTriangle as EquilateralTriangle:
            initialShapeRotation = equilateralTriangle.initialRotation
            
            // we are treating odd and even columns separately.
            // -1st & 0th columns are tiled together
            // 1st & 2nd columns are tiled together,
            // 3rd & 4th columns are tiled together, and so on...
            let columnMultiplier: CGFloat = CGFloat((tileX + 1)/2)
            
            
            // since this shape is an equilateral triangle, the degrees of 30 and 60 are coming from that
            // to calculate the constant, we need to perform:
            // let constant = sin(CommonAngle(degrees: 30).radians / sin(CommonAngle(degrees: 60).radians))
            // sin(30) = 1/2 | sin(60) = √3/2 => constant = 1/√3
            // let constant = 1.0/sqrt(3.0)
            let trigonometricConstant = 1.0/sqrt(3)
            
            let offsetFromStaggeringX = (columnMultiplier * appliedstaggerEffectValue * trigonometricConstant)
            
            // staggering value can be so high that the polygons could be drawn out of bounds in the y dimension
            // we need to apply a modulus (i.e. correction) so that it pulls all the polygons upwards so that
            // all the polygons will still be visible - within the bounds of the canvas
            let modulusAppliedWhenStaggeringForY = tileSize.height + interTileSpacing
            let offsetFromStaggeringY = (columnMultiplier * appliedstaggerEffectValue).truncatingRemainder(dividingBy: modulusAppliedWhenStaggeringForY)
            
            let tilingXOffset = CGFloat(tileX) * (tileSize.width - (tileSize.width / 2) + interTileSpacing) + paddingAroundTheEdges
            let tilingYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges

            
            tileXOffset = tilingXOffset + offsetFromStaggeringX
            tileYOffset = tilingYOffset + offsetFromStaggeringY
        case let aSquare as Square:
            initialShapeRotation = aSquare.initialRotation
            
            // offset from stagger effect will change depending on the axis
            let offsetFromStaggering: CGFloat
            let totalModulus: CGFloat
            let modulatedStaggerOffsetForXAxis: CGFloat
            let modulatedStaggerOffsetForYAxis: CGFloat
            
            switch providedStaggerEffect.axis {
            case .yAxis:
                offsetFromStaggering = (CGFloat(tileX) * appliedstaggerEffectValue)
                totalModulus = tileSize.height + interTileSpacing
                modulatedStaggerOffsetForXAxis = 0
                modulatedStaggerOffsetForYAxis = offsetFromStaggering.truncatingRemainder(dividingBy: totalModulus) //- (totalModulus)
            /*
            case .xAxis:
                offsetFromStaggering = (CGFloat(tileY) * appliedstaggerEffectValue)
                totalModulus = tileSize.width + interTileSpacing
                modulatedStaggerOffsetForXAxis = offsetFromStaggering.truncatingRemainder(dividingBy: totalModulus) //- (totalModulus)
                modulatedStaggerOffsetForYAxis = 0
            */
            }
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffsetForXAxis
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffsetForYAxis
            
        case let aRectangle as Quadgon:
            initialShapeRotation = aRectangle.initialRotation
            
            // offset from stagger effect will change depending on the axis
            let offsetFromStaggering: CGFloat
            let totalModulus: CGFloat
            let modulatedStaggerOffsetForXAxis: CGFloat
            let modulatedStaggerOffsetForYAxis: CGFloat
            
            switch providedStaggerEffect.axis {
            case .yAxis:
                offsetFromStaggering = (CGFloat(tileX) * appliedstaggerEffectValue)
                totalModulus = tileSize.height + interTileSpacing
                modulatedStaggerOffsetForXAxis = 0
                modulatedStaggerOffsetForYAxis = offsetFromStaggering.truncatingRemainder(dividingBy: totalModulus) //- (totalModulus)
            }
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffsetForXAxis
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffsetForYAxis
        case let aHexagon as Hexagon:
            initialShapeRotation = aHexagon.initialRotation
            appliedstaggerEffectValue = 0.0 //additional staggering is not supported for hexagon
            
            // because a hexagon's base length is half the width of its enclosing square
            // we need half of that amount in negative offset so that each hexagon fits nicely
            // in a staggered way
            let baseLength = tileSize.width / 2.0
            let negativeOffsetNeededForGaplessTiling = baseLength / 2.0
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing - negativeOffsetNeededForGaplessTiling) + paddingAroundTheEdges
            if isProcessingOddColumn {
                tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + ((tileSize.height / 2.0) + (paddingAroundTheEdges * 2))
            } else {
                //even indexes we will tile them where they normally go
                tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
            }
        case let anOctagon as Octagon:
            initialShapeRotation = anOctagon.initialRotation
            let offsetFromStaggeringY = (CGFloat(tileX) * appliedstaggerEffectValue)
            
            let totalModulus = tileSize.height + interTileSpacing
            let modulatedStaggerOffset = offsetFromStaggeringY.truncatingRemainder(dividingBy: totalModulus)
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges + modulatedStaggerOffset
            
        default:
            tileXOffset = CGFloat(tileX) * (tileSize.width + interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + interTileSpacing) + paddingAroundTheEdges
        }
        
        let boundingRectOfTile = CGRect(origin: CGPoint(x: tileXOffset,
                                                  y: tileYOffset),
                                  size: tileSize)
        
        // because we always draw an extra polygon around the edges of the screen
        // there will be some instances, where that extra polygon is not needed
        // if those polygons are completely out of bounds, then we can skip drawing them
        let isOutOfBounds = !canvasRect.intersects(boundingRectOfTile)
        
        // we need to calculate the middle point of the tile
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: boundingRectOfTile.midX, y: boundingRectOfTile.midY)
        
        // the polygon points may be located on a circle - hence the radius calculation
        let radius = min(boundingRectOfTile.width,boundingRectOfTile.height) / 2.0 - interTileSpacing / 2.0
        
        return TilingLayoutMetrics(tileXOffset: tileXOffset,
                                   tileYOffset: tileYOffset,
                                   initialShapeRotation: initialShapeRotation.radians,
                                   appliedStaggerEffect: appliedstaggerEffectValue, 
                                   boundingRect: boundingRectOfTile, 
                                   isOutOfBounds: isOutOfBounds,
                                   centerPoint: centerPoint,
                                   radius: radius)
    }
}

#Preview {
    let backgroundColor = Color(white: 0.85) //light gray

    // configure the polygon
    let tiledPolygon = TiledPolygon()
        .kind(Hexagon())
        .interTileSpacing(2)
        //.staggerEffect(StaggerEffect(0, axis: .yAxis))
        .fillColorPattern(Color.viridisPalette)
        .polygonSize(TileablePolygonSize(horizontalPolygonTarget: 12))
        .background(backgroundColor)
        .padding(0)
    
    return tiledPolygon
}
