//
//  Polygon.swift
//  
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct Polygon: View {
    public var borderWidth: CGFloat = 1.0
    
    public var borderColor: Color = .black
    
    public var showDashes: Bool = false
    
    public var fillColor: Color = .blue
        
    public var numberOfSides: Int = 4 {
        didSet {
            if numberOfSides < 3 {
                numberOfSides = 3
            } else if numberOfSides > 120 {
                numberOfSides = 120
            }
        }
    }
    
    public var rotationAngle: Angle = .zero
    
    public init(borderWidth: CGFloat = 1.0,
                borderColor: Color = .black,
                showDashes: Bool = false,
                fillColor: Color = .blue,
                numberOfSides: Int = 4,
                rotationAngle: Angle = .zero) {
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.showDashes = showDashes
        self.fillColor = fillColor
        self.numberOfSides = numberOfSides
        self.rotationAngle = rotationAngle
    }
    
    public init() {}
    
    public var body: some View {
        Canvas { context, size in
            let boundingRect = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
            // we need to calculate the middle point of our frame
            // we will use this center as an anchor to draw our polygon
            let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)

            // the polygon points will be located on a circle - hence the radius calculation
            // this radius calculation also takes into account the border width which gets
            // added on the outside of the shape
            let radius = min(boundingRect.width, boundingRect.height) / 2.0 - borderWidth / 2.0
            let polygonPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
            
            
            drawDashes(rect: boundingRect, center: centerPoint, radius: radius, context: context)
            let scaledPolygonPath = scale(originalPath: polygonPath, rect: boundingRect, originalCenter: centerPoint, reCenter: true)
                        
            context.stroke(scaledPolygonPath, with: .color(borderColor), style: StrokeStyle(lineWidth: borderWidth))
            context.fill(scaledPolygonPath, with: .color(fillColor))
        }
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    public func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> Path {
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
    
    public func drawDashes(rect: CGRect, center: CGPoint, radius: CGFloat, context: GraphicsContext) {
        if showDashes {
            var dashedCirclePath = Path()
            dashedCirclePath.addArc(center: center, radius: radius, startAngle: Angle.zero, endAngle: Angle(degrees: 360), clockwise: true)
            context.stroke(dashedCirclePath, with: .color(.black), style: StrokeStyle(lineWidth: 1.5, dash: [4, 8], dashPhase: 0))
        }
    }
    
    public func scale(originalPath: Path, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> Path {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = originalPath.boundingRect
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + 2 * borderWidth)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + 2 * borderWidth)
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
    var polygon = Polygon(numberOfSides: 7)
    polygon.fillColor = .blue
    polygon.borderWidth = 3.0
    polygon.borderColor = .black
    polygon.rotationAngle = Angle(degrees: 30)
    return polygon
}
