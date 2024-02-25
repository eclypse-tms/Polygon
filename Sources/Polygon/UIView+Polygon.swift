//
//  UIView+Polygon.swift
//
//
//  Created by eclypse on 2/23/24.
//

import UIKit

public protocol EquilateralPolygon: UIView {
    /// whether to show dashes around the circle that the initial
    /// polygon is rendered before scaling and rotation. used in the 
    /// accompanying blog for demonstration purposes.
    var showDashes: Bool { get set }
    
    /// the color to fill the polygon with
    var fillColor: UIColor { get set }
    
    /// optional border color. only works when the width is greater than 0
    var borderColor: UIColor { get set }
    
    /// optional border width. specify zero to negate the border
    var borderWidth: CGFloat { get set }
    
    /// number of equal sides
    var numberOfSides: Int { get set }
    
    /// Rotation angle expressed in degrees, i.e. 45° or 120°
    var rotationAngle: CGFloat { get set }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> UIBezierPath
    
    /// rotates the given bezier path and re-centers the shape in the bounding rectangle
    func rotate(polygonPath: UIBezierPath, originalCenter: CGPoint, reCenter: Bool)
    
    /// scales the bezier path to fit the bounding rectangle, if necessary
    func scale(polygonPath: UIBezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool)
}

extension EquilateralPolygon {
    
    public func scale(polygonPath: UIBezierPath, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = polygonPath.bounds
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + 2 * borderWidth)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + 2 * borderWidth)
        let finalScaleFactor = min(scaleFactorX, scaleFactorY)
        
        if abs(finalScaleFactor - 1.0) < 0.001 {
            // either the height or width of the shape is already at it max
            // the shape cannot be scaled any further
        } else {
            // scale the shape based on the calculated scale factor
            let scaledAffineTransform = CGAffineTransform(scaleX: finalScaleFactor, y: finalScaleFactor)
            polygonPath.apply(scaledAffineTransform)
            
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
        }
    }
    
    /// rotates the given bezier path and re-centers the shape in the bounding rectangle
    public func rotate(polygonPath: UIBezierPath, originalCenter: CGPoint, reCenter: Bool) {
        if abs(rotationAngle.truncatingRemainder(dividingBy: 360.0)) < 0.01 {
            // no rotation needs to be applied, since rotation angle is essentially zero
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
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    public func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> UIBezierPath {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(numberOfSides)
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var points = [CGPoint]()
        for i in 0..<numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let x = centerPoint.x + radius * cos(currentAngleFromCenter)
            let y = centerPoint.y + radius * sin(currentAngleFromCenter)
            points.append(CGPoint(x: x, y: y))
        }

        // now convert the points to lines on a bezier path
        let path = UIBezierPath()
        path.move(to: points[0])
        for point in points[1..<points.count] {
            path.addLine(to: point)
        }
        path.close()
        return path
    }
    
    public func drawDashes(rect: CGRect, center: CGPoint, radius: CGFloat) {
        if showDashes {
            let dashedCirclePath = UIBezierPath(arcCenter: center,
                                                radius: radius,
                                                startAngle: 0,
                                                endAngle: 2 * CGFloat.pi,
                                                clockwise: true)
            dashedCirclePath.setLineDash([4.0, 6.0], count: 2, phase: 0.0)
            UIColor.darkGray.setStroke()
            dashedCirclePath.stroke()
        }
    }
}
