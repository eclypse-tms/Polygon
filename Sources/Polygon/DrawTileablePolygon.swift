//
//  DrawTileablePolygon.swift
//
//
//  Created by eclypse on 3/13/24.
//

import Foundation

/// performs operations that produce a bezier path like drawing a polygon path or scaling an existing one
public protocol DrawTileablePolygon {
    /// given a center point and radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - numberOfSides: number of sides of any equilateral polygon.
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    func drawInitialPolygonPath(numberOfSides: Int,
                                centerPoint: CGPoint,
                                radius: CGFloat,
                                rotationInRadians: CGFloat?) -> BezierPath
    
    /// given a rectangle, center point and a radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - kind: the type of polygon that needs to be drawn.
    ///   - boundingRect: the rectangle with which to draw the bezier path
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    func drawPolygonPath(kind: any TileablePolygonKind,
                         boundingRect: CGRect,
                         centerPoint: CGPoint,
                         radius: CGFloat,
                         rotationInRadians: CGFloat?) -> BezierPath
    
    /// scales the original path so that at least 2 corners of the polygon touches the edge of the frame
    func scale(originalPath: BezierPath, 
               rect: CGRect,
               originalCenter: CGPoint,
               reCenter: Bool,
               borderWidth: CGFloat?) -> BezierPath
}

    
public extension DrawTileablePolygon {   
    /// given a center point and radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - numberOfSides: number of sides of any equilateral polygon.
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    func drawInitialPolygonPath(numberOfSides: Int,
                                centerPoint: CGPoint,
                                radius: CGFloat,
                                rotationInRadians: CGFloat?) -> BezierPath {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = BezierPath()
        for i in 0..<numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + (rotationInRadians ?? 0.0)
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
    
    
    /// given a center point and radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - kind: the type of polygon that needs to be drawn.
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    func drawPolygonPath(kind: any TileablePolygonKind,
                         boundingRect: CGRect,
                         centerPoint: CGPoint,
                         radius: CGFloat,
                         rotationInRadians: CGFloat?) -> BezierPath {
        // instantiate the path
        
        
        if kind.hasEquilateralSides {
            var polygonPath = BezierPath()
            // since this is an equilateral polygon, we can draw a circle and place
            // the corners on this circle.
            // this is the slice we have to traverse for each side of the polygon
            let angleSliceFromCenter = 2 * .pi / CGFloat(kind.numberOfSides)
            
            // iterate over the sides of the polygon and collect each point on the circle
            // where the polygon corner should be
            
            for i in 0..<kind.numberOfSides {
                let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
                let rotatedAngleFromCenter = currentAngleFromCenter + (rotationInRadians ?? 0.0)
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
        } else {
            var polygonPath: BezierPath
            switch kind {
            case is Quadgon:
                fallthrough
            default:
                polygonPath = BezierPath(for: boundingRect, cornerRadius: 0.0)
            }
            
            return polygonPath
        }
    }
    
    /// scales the original path so that at least 2 corners of the polygon touches the edge of the frame
    func scale(originalPath: BezierPath,
               rect: CGRect,
               originalCenter: CGPoint,
               reCenter: Bool,
               borderWidth: CGFloat?) -> BezierPath {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = originalPath.boundingRect
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + 2 * (borderWidth ?? 0.0))
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + 2 * (borderWidth ?? 0.0))
        let finalScaleFactor = min(scaleFactorX, scaleFactorY)
        
        if abs(finalScaleFactor - 1.0) < 0.000001 {
            // either the height or width of the shape is already at it max
            // the shape cannot be scaled any further
            return originalPath
        } else {
            // scale the shape based on the calculated scale factor
            let scaledAffineTransform = CGAffineTransform(scaleX: finalScaleFactor, y: finalScaleFactor)
            let scaledNonCenteredPath = originalPath.transform(scaledAffineTransform, in: rect)
            
            if reCenter {
                // scaling operation happens with respect to the origin/anchor point
                // as a result, scaling the polygon will shift its center
                // we need to bring the shape back to the original rectangle's center
                let centerAfterScaling = CGPoint(x: scaledNonCenteredPath.boundingRect.midX, y: scaledNonCenteredPath.boundingRect.midY)
                let recenteredAffineTransform = CGAffineTransform(translationX: originalCenter.x - centerAfterScaling.x, y: originalCenter.y - centerAfterScaling.y)
                return scaledNonCenteredPath.transform(recenteredAffineTransform, in: rect)
            } else {
                // we don't need to recenter, we are done!
                return scaledNonCenteredPath
            }
        }
    }
}
