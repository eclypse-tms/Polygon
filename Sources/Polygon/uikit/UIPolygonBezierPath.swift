//
//  UIPolygonBezierPath.swift
//
//
//  Created by eclypse on 3/2/24.
//

#if canImport(UIKit)
import UIKit


/// performs operations that produce a bezier path like drawing a polygon path or scaling an existing one
public protocol UIPolygonBezierPath {
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
                                rotationInRadians: CGFloat?) -> UIBezierPath
    
    
    /// scales the bezier path to fit the bounding rectangle, if necessary
    func scale(polygonPath: UIBezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool, borderWidth: CGFloat?) -> UIBezierPath
    
    /// rotates the given bezier path and re-centers the shape in the bounding rectangle
    func rotate(polygonPath: UIBezierPath, originalCenter: CGPoint, reCenter: Bool, rotationAngle: CGFloat) -> UIBezierPath
}

extension UIPolygonBezierPath {
    
    /// scales the bezier path to fit the bounding rectangle, if necessary
    public func scale(polygonPath: UIBezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool, borderWidth: CGFloat?) -> UIBezierPath {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = polygonPath.bounds
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + 2 * (borderWidth ?? 0.0))
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + 2 * (borderWidth ?? 0.0))
        let finalScaleFactor = min(scaleFactorX, scaleFactorY)
        
        if abs(finalScaleFactor - 1.0) < 0.000001 {
            // either the height or width of the shape is already at it max
            // the shape cannot be scaled any further
            return polygonPath
        } else {
            // scale the shape based on the calculated scale factor
            let scaledAffineTransform = CGAffineTransform(scaleX: finalScaleFactor, y: finalScaleFactor)
            polygonPath.apply(scaledAffineTransform)
            
            //at this point, original path has been scaled but not centered
            if reCenter {
                // scaling operation happens with respect to the origin/anchor point
                // as a result, scaling the polygon will shift its center
                // we need to bring the shape back to the original rectangle's center
                let centerAfterScaling = CGPoint(x: polygonPath.bounds.midX, y: polygonPath.bounds.midY)
                let recenteredAffineTransfor = CGAffineTransform(translationX: originalCenter.x - centerAfterScaling.x, y: originalCenter.y - centerAfterScaling.y)
                polygonPath.apply(recenteredAffineTransfor)
            } else {
                // we don't need to recenter, we are done!
            }
            return polygonPath
        }
    }
    
    /// given a center point and radius, it creates a bezier path for a TileablePolygonKind
    /// - Parameters:
    ///   - numberOfSides: number of sides of any equilateral polygon.
    ///   - centerPoint: center point in its bounding rectangle
    ///   - radius: radius of the biggest circle that can be drawn in its bounding rectangle
    ///   - rotationAngle: optional rotation to apply in radians
    /// - Returns: a path of the polygon
    public func drawInitialPolygonPath(numberOfSides: Int,
                                centerPoint: CGPoint,
                                radius: CGFloat,
                                rotationInRadians: CGFloat?) -> UIBezierPath {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        let polygonPath = UIBezierPath()
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

        polygonPath.close()
        return polygonPath
    }
    
    /// rotates the given bezier path and re-centers the shape in the bounding rectangle
    public func rotate(polygonPath: UIBezierPath, originalCenter: CGPoint, reCenter: Bool, rotationAngle: CGFloat) -> UIBezierPath {
        if abs(rotationAngle.truncatingRemainder(dividingBy: 360.0)) < 0.01 {
            // no rotation needs to be applied, since rotation angle is essentially zero
            return polygonPath
        } else {
            // Apply the rotation transformation to the original path
            // rotation happens around the origin (which is the upper left corner in iOS)
            let rotationAffineTransform = CGAffineTransform(rotationAngle: rotationAngle.toRadians())
            polygonPath.apply(rotationAffineTransform)
            
            if reCenter {
                // now that the bezier path is rotated according to the provided angle around the origin/anchor,
                // we should re-center the path in the bounding rectangle
                let rotatedCenter = CGPoint(x: polygonPath.bounds.midX, y: polygonPath.bounds.midY)
                let centerAfterRotationAffineTransform = CGAffineTransform(translationX: originalCenter.x - rotatedCenter.x, y: originalCenter.y - rotatedCenter.y)
                polygonPath.apply(centerAfterRotationAffineTransform)
            } else {
                // we don't need to recenter, we are done!
            }
            return polygonPath
        }
    }
}
#endif
