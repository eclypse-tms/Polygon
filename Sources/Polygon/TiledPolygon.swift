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
                let deducedSize = deduceMetricsForFlexiblePolygonSize(canvasSize: canvasSize, targetNumberOfHorizontallyLaidPolygons: validNumberOfHorizontalPolygons)
                numberOfTileableColumns = deducedSize.numberOfTileableColumns
                numberOfTileableRows = deducedSize.numberOfTileableRows
                effectiveTileSize = deducedSize.effectiveTileSize
            } else {
                let deducedSize = deduceMetricsForFixedPolygonSize(canvasSize: canvasSize)
                numberOfTileableColumns = deducedSize.numberOfTileableColumns
                numberOfTileableRows = deducedSize.numberOfTileableRows
                effectiveTileSize = deducedSize.effectiveTileSize
            }
            
            // due to staggering effect, we need to tile around the edges of the canvas
            // for this reason our lower bounds start at -1
            // and upper bounds end at numberOfTileableColumns + 1
            let rowLowerBound = 0
            let rowUpperBound = numberOfTileableRows + 1
            let columnLowerBound = -1
            let columnUpperBound = numberOfTileableColumns + 1
            
            var loopCounter = -1
            
            //at this point we determined how many rows and columns we would need to tile
            //now we need to iterate over the rows and columns
            for tileX in columnLowerBound..<columnUpperBound {
                //tileX and tileY follows the same X,Y coordinate pattern in a coordinate space.
                //when tileX is zero, we are referring to the first columnns of shapes
                //when tileY is zero, we are referring to the first row of shapes
                //therefore, when tileX = 2
                for tileY in rowLowerBound..<rowUpperBound {
                    loopCounter += 1
                    
                    // calculate the layout metrics of each tile
                    let layoutMetrics = performLayout(tileX: tileX, tileY: tileY, tileSize: effectiveTileSize)
                    
                    // apply out of bounds correction if necessary
                    let boundingRect = outOfBoundsCorrectionIfNecessary(canvasSize: canvasSize,
                                                       individualTileSize: effectiveTileSize,
                                                       currentOffset: CGPoint(x: layoutMetrics.tileXOffset, y: layoutMetrics.tileYOffset),
                                                       requestedStaggerEffect: layoutMetrics.appliedStaggerEffect,
                                                       numberOfTileableRows: numberOfTileableRows,
                                                       polygonKind: _kind)
                    
                    // we need to calculate the middle point of our frame
                    // we will use this center as an anchor to draw our polygon
                    let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
                    
                    // the polygon points will be located on a circle - hence the radius calculation
                    // this radius calculation also takes into account the border width which gets
                    // added on the outside of the shape
                    let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _interTileSpacing / 2.0
                    var finalShapeRotation = Angle(radians: layoutMetrics.initialShapeRotation)
                    switch _kind {
                    case is EquilateralTriangle:
                        if tileX.isOdd() {
                            //we need to reverse the rotation 180 degrees when
                            finalShapeRotation = Angle(radians: layoutMetrics.initialShapeRotation + Double.pi)
                        }
                    default:
                        // other shapes do not need additional rotation
                        break
                    }
                    
                    let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius, initialRotation: finalShapeRotation)
                    
                    let scaledPolygonPath = scale(originalPath: initialPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
      
                    let colorMod = loopCounter % _fillColorPattern.count
                    
                    context.fill(scaledPolygonPath, with: .color(_fillColorPattern[colorMod]))
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
    
    /// scales the original path so that at least 2 corners of the polygon touches the edge of the frame
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
    
    
    /// given row and column tiling assignment, calculates the layout metrics (i.e. where it should be laid within the canvas)
    /// - Parameters:
    ///   - tileX: refers to the tiles that are laid out horizontally, like the x dimension
    ///   - tileY: refers to the tiles that are laid out vertically, like the y dimension
    ///   - tileSize: size to use when performing calculations - provide the effective tile size
    /// - Returns: metrics on how to lay this tile within the given canvas. does not apply out of bounds correction
    private func performLayout(tileX: Int, tileY: Int, tileSize: CGSize) -> TiledPolygonLayoutMetrics {
        let tileXOffset: CGFloat
        let tileYOffset: CGFloat
        // apply half of the inter tile spacing around the edges to make it look right
        let paddingAroundTheEdges = CGFloat(_interTileSpacing / 2.0)
        
        // for triangles and hexagons, we need to performs translation and rotation
        // for this reason, we need to know whether we are processing the odd column at the moment
        let isProcessingOddColumn = tileX.isOdd()
        
        var appliedStaggerValue = CGFloat(0)
        var initialShapeRotation = Angle.zero
        
        switch _kind {
        case let equilateralTriangle as EquilateralTriangle:
            appliedStaggerValue = equilateralTriangle.staggerEffect
            initialShapeRotation = equilateralTriangle.initialRotation
            
            let finalXStaggeringOffset: CGFloat
            let finalYStaggeringOffset: CGFloat
            if tileX.isEven() {
                finalXStaggeringOffset = CGFloat(tileX / 2) * appliedStaggerValue * sin(Angle(degrees: 30).radians / sin(Angle(degrees: 60).radians))
                finalYStaggeringOffset = (CGFloat(tileX / 2) * appliedStaggerValue)
            } else {
                if tileX == -1 {
                    //special case for column -1 // no staggering effect needed
                    finalXStaggeringOffset = 0
                    finalYStaggeringOffset = 0
                } else {
                    finalXStaggeringOffset = CGFloat((tileX / 2) + 1) * appliedStaggerValue * sin(Angle(degrees: 30).radians / sin(Angle(degrees: 60).radians))
                    finalYStaggeringOffset = (CGFloat((tileX / 2) + 1) * appliedStaggerValue)
                }
            }
            
            let primaryXOffset = CGFloat(tileX) * (tileSize.width + _interTileSpacing) + paddingAroundTheEdges
            let primaryYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + paddingAroundTheEdges
            let xCorrection = CGFloat(tileX) * (tileSize.width / 2)
            
            tileXOffset = primaryXOffset - xCorrection + finalXStaggeringOffset
            tileYOffset = primaryYOffset + finalYStaggeringOffset
        case let aSquare as Square:
            initialShapeRotation = aSquare.initialRotation
            appliedStaggerValue = aSquare.staggerEffect
            let staggerOffsetPerColumn = (CGFloat(tileX) * appliedStaggerValue)
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + _interTileSpacing) + paddingAroundTheEdges
            
            if tileX == 1 {
                tileYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + paddingAroundTheEdges + staggerOffsetPerColumn - 90
            } else {
                tileYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + paddingAroundTheEdges + staggerOffsetPerColumn
            }
        case let hexagon as Hexagon:
            initialShapeRotation = hexagon.initialRotation
            appliedStaggerValue = hexagon.staggerEffect
            
            tileXOffset = CGFloat(tileX) * (tileSize.width + _interTileSpacing) - (CGFloat(tileX) * (tileSize.width / 4)) + paddingAroundTheEdges
            if isProcessingOddColumn {
                tileYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + ((tileSize.height / 2.0) + (paddingAroundTheEdges * 2))
            } else {
                //even indexes we will tile them where they normally go
                tileYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + paddingAroundTheEdges
            }
        default:
            tileXOffset = CGFloat(tileX) * (tileSize.width + _interTileSpacing) + paddingAroundTheEdges
            tileYOffset = CGFloat(tileY) * (tileSize.height + _interTileSpacing) + paddingAroundTheEdges
        }
        
        return TiledPolygonLayoutMetrics(tileXOffset: tileXOffset,
                                         tileYOffset: tileYOffset,
                                         initialShapeRotation: initialShapeRotation.radians,
                                         appliedStaggerEffect: appliedStaggerValue)
    }
    
    /// calculates a new bounding rectangle for those tiles that are drawn completely out of canvas
    /// bounds due to staggering effect
    private func outOfBoundsCorrectionIfNecessary(canvasSize: CGSize,
                                 individualTileSize: CGSize,
                                 currentOffset: CGPoint,
                                 requestedStaggerEffect: CGFloat,
                                 numberOfTileableRows: Int,
                                 polygonKind: TilablePolygonKind) -> CGRect {
        let boundingRect: CGRect
        let outOfBoundsDetectionLimit = canvasSize.height
        let isDrawingCompletelyOutOfBounds = currentOffset.y > outOfBoundsDetectionLimit
        
        if isDrawingCompletelyOutOfBounds {
            //the offset is so much that we are drawing entirely out of bounds
            //correct this so that we are in-bounds again from the top, like infinity screen
            let correctedYOffset: CGFloat
            switch polygonKind {
            case is EquilateralTriangle:
                correctedYOffset = requestedStaggerEffect/2.0 - (canvasSize.height + individualTileSize.height)
            case is Square, is Hexagon:
                correctedYOffset = currentOffset.y - (CGFloat(numberOfTileableRows) * (individualTileSize.height + _interTileSpacing))
            default:
                correctedYOffset = currentOffset.y
            }
            boundingRect = CGRect(origin: CGPoint(x: currentOffset.x, y: correctedYOffset), size: individualTileSize)
        } else {
            boundingRect = CGRect(origin: CGPoint(x: currentOffset.x, y: currentOffset.y), size: individualTileSize)
        }
        
        return boundingRect
    }
    
    
    /// You use this when the request is to layout a fixed number of polygons horizontally.
    /// It determines the size of each tile as well as how many rows of tiles are needed.
    private func deduceMetricsForFlexiblePolygonSize(canvasSize: CGSize, targetNumberOfHorizontallyLaidPolygons: CGFloat) -> DeducedTilingMetrics {
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
            let halfOfHorizontalPolygons = (targetNumberOfHorizontallyLaidPolygons / 2.0).rounded(.down)
            let halfOfHorizontalPolygons2 = ((targetNumberOfHorizontallyLaidPolygons / 2.0) + 0.5)
            widthOfEachTile = (canvasWidthAfterInterTilingGapIsApplied - halfOfHorizontalPolygons) / halfOfHorizontalPolygons2
            
            // because this is a triangle, in order to have a fitting frame, we need to calculate
            // the fitting height for the given width.
            heightOfEachTile = widthOfEachTile * sin(Angle(degrees: (60)).radians)
            
        case is Square:
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
            heightOfEachTile = widthOfEachTile * sin(Angle(degrees: 60).radians)
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
    
    
    /// You use this when the request is to tile polygons with a fixed size. It determines how many
    /// polygons are needed horizontally and vertically to fit the available canvas.
    private func deduceMetricsForFixedPolygonSize(canvasSize: CGSize) -> DeducedTilingMetrics {
        let numberOfTileableColumns: Int
        let numberOfTileableRows: Int
        let effectiveTileSize: CGSize
        
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
        
        return DeducedTilingMetrics(numberOfTileableColumns: numberOfTileableColumns,
                                     numberOfTileableRows: numberOfTileableRows,
                                     effectiveTileSize: effectiveTileSize)
    }
}

#Preview {
    let backgroundColor = Color(white: 0.85) //light gray

    // configure the polygon
    let tiledPolygon = TiledPolygon()
        .kind(Hexagon())
        .interTileSpacing(2)
        .fillColorPattern(Color.magmaColorPalette)
        .polygonSize(TilablePolygonSize(horizontalPolygonTarget: 14))
        .background(backgroundColor)
        .padding(16)
    
    return tiledPolygon
}
