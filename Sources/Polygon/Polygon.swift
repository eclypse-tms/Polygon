//
//  Polygon.swift
//  
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct Polygon: Shape {
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
        
    public init(numberOfSides: Int = 4,
                fillColor: Color = .blue,
                rotationAngle: Angle = .zero,
                borderWidth: CGFloat = 1.0,
                borderColor: Color = .black,
                showDashes: Bool = false) {
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
            
            drawDashes(rect: boundingRect, center: centerPoint, radius: radius, context: context)
            
            let scaledPolygonPath = path(in: boundingRect)
            context.stroke(scaledPolygonPath, with: .color(borderColor), style: StrokeStyle(lineWidth: borderWidth))
            context.fill(scaledPolygonPath, with: .color(fillColor))
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        // we need to calculate the middle point of our frame
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // the polygon points will be located on a circle - hence the radius calculation
        // this radius calculation also takes into account the border width which gets
        // added on the outside of the shape
        let radius = min(rect.width, rect.height) / 2.0 - borderWidth / 2.0
        
        let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
        let scaledPolygonPath = scale(originalPath: initialPath, rect: rect, originalCenter: centerPoint, reCenter: true)
        return scaledPolygonPath
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
    
    private func drawDashes(rect: CGRect, center: CGPoint, radius: CGFloat, context: GraphicsContext) {
        if showDashes {
            var dashedCirclePath = Path()
            dashedCirclePath.addArc(center: center, radius: radius, startAngle: Angle.zero, endAngle: Angle(degrees: 360), clockwise: true)
            context.stroke(dashedCirclePath, with: .color(.black), style: StrokeStyle(lineWidth: 1.5, dash: [4, 8], dashPhase: 0))
        }
    }
    
    private func scale(originalPath: Path, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> Path {
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
    let lightGray = Color(white: 0.85)
    var hStack = HStack(spacing: 20, content: {
      Polygon(numberOfSides: 3, fillColor: .blue, rotationAngle: Angle(degrees: 30))
        .background(lightGray)
      Polygon(numberOfSides: 4, fillColor: .blue, rotationAngle: Angle(degrees: 45))
        .background(lightGray)
      Polygon(numberOfSides: 5, fillColor: .blue, rotationAngle: Angle(degrees: -18))
        .background(lightGray)
      Polygon(numberOfSides: 6, fillColor: .blue, rotationAngle: Angle(degrees: 0))
        .background(lightGray)
    })
    .frame(maxHeight: 360)
    .padding()
    
    return hStack
}
