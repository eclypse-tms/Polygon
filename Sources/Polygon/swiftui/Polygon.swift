//
//  Polygon.swift
//  
//
//  Created by eclypse on 3/2/24.
//

import SwiftUI

/// Polygon allows you to add a polygon of any sides to your SwiftUI based views
public struct Polygon: Shape {
    
    @usableFromInline
    internal var _numberOfSides: Int = 4
    
    /// number of equal sides
    @inlinable public func numberOfSides(_ number: Int) -> Self {
        var newCopy = self
        if number < 3 {
            newCopy._numberOfSides = 3
        } else if number > 120 {
            newCopy._numberOfSides = 120
        } else {
            newCopy._numberOfSides = number
        }
        return newCopy
    }
    
    @usableFromInline
    internal var _fillColor: Color = .blue
    
    /// the color to fill the polygon with
    @inlinable public func fillColor(_ aColor: Color) -> Self {
        var newCopy = self
        newCopy._fillColor = aColor
        return newCopy
    }
    
    @usableFromInline
    internal var _rotationAngle: Angle = .zero
    
    /// Rotation angle expressed in degrees (for ex: 45°) or radians (for ex: π/4)
    @inlinable public func rotationAngle(_ angle: Angle) -> Self {
        var newCopy = self
        newCopy._rotationAngle = angle
        return newCopy
    }
    

    @usableFromInline
    internal var _borderWidth: CGFloat = 1.0
    
    /// optional border width. specify zero to negate the border
    @inlinable public func borderWidth(_ aWidth: CGFloat) -> Self {
        var newCopy = self
        newCopy._borderWidth = aWidth
        return newCopy
    }
    
    
    @usableFromInline
    internal var _borderColor: Color = .black
    
    /// optional border color. only works when the border width is greater than 0
    @inlinable public func borderColor(_ aColor: Color) -> Self {
        var newCopy = self
        newCopy._borderColor = aColor
        return newCopy
    }
    
    @usableFromInline
    internal var _showDashes: Bool = false
    
    /// whether to show dashes around the circle that the initial
    /// polygon is rendered before scaling and rotation. used in the
    /// accompanying blog for demonstration purposes.
    @inlinable public func showDashes(_ show: Bool) -> Self {
        var newCopy = self
        newCopy._showDashes = show
        return newCopy
    }
    
    public init(numberOfSides: Int) {
        if numberOfSides < 3 {
            self._numberOfSides = 3
        } else if numberOfSides > 120 {
            self._numberOfSides = 120
        } else {
            self._numberOfSides = numberOfSides
        }
    }
    
    public var body: some View {
        Canvas { context, size in
            let boundingRect = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
            // we need to calculate the middle point of our frame
            // we will use this center as an anchor to draw our polygon
            let centerPoint = CGPoint(x: boundingRect.midX, y: boundingRect.midY)
            
            // the polygon points will be located on a circle - hence the radius calculation
            // this radius calculation also takes into account the border width which gets
            // added on the outside of the shape
            let radius = min(boundingRect.width, boundingRect.height) / 2.0 - _borderWidth / 2.0
            
            drawDashes(rect: boundingRect, center: centerPoint, radius: radius, context: context)
            
            let scaledPolygonPath = path(in: boundingRect)
            context.stroke(scaledPolygonPath, with: .color(_borderColor), style: StrokeStyle(lineWidth: _borderWidth))
            context.fill(scaledPolygonPath, with: .color(_fillColor))
        }
    }
    
    public func path(in rect: CGRect) -> Path {
        // we need to calculate the middle point of our frame
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // the polygon points will be located on a circle - hence the radius calculation
        // this radius calculation also takes into account the border width which gets
        // added on the outside of the shape
        let radius = min(rect.width, rect.height) / 2.0 - _borderWidth / 2.0
        
        let initialPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
        let scaledPolygonPath = scale(originalPath: initialPath, rect: rect, originalCenter: centerPoint, reCenter: true)
        return scaledPolygonPath
    }
    
    /// given a center point and radius, it creates a bezier path for an equilateral Polygon
    private func drawInitialPolygonPath(centerPoint: CGPoint, radius: CGFloat) -> Path {
        // this is the slice we have to traverse for each side of the polygon
        let angleSliceFromCenter = 2 * .pi / CGFloat(_numberOfSides)
        
        
        // iterate over the sides of the polygon and collect each point on the circle
        // where the polygon corner should be
        var polygonPath = Path()
        for i in 0..<_numberOfSides {
            let currentAngleFromCenter = CGFloat(i) * angleSliceFromCenter
            let rotatedAngleFromCenter = currentAngleFromCenter + _rotationAngle.radians
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
        if _showDashes {
            var dashedCirclePath = Path()
            dashedCirclePath.addArc(center: center, radius: radius, startAngle: Angle.zero, endAngle: Angle(degrees: 360), clockwise: true)
            context.stroke(dashedCirclePath, with: .color(.black), style: StrokeStyle(lineWidth: 1.5, dash: [4, 8], dashPhase: 0))
        }
    }
    
    private func scale(originalPath: Path, rect: CGRect, originalCenter: CGPoint, reCenter: Bool) -> Path {
        // 1. calculate the scaling factor to touch all the edges
        let boundingRectOfRotatedPath = originalPath.boundingRect
        let scaleFactorX = rect.width / (boundingRectOfRotatedPath.width + 2 * _borderWidth)
        let scaleFactorY = rect.height / (boundingRectOfRotatedPath.height + 2 * _borderWidth)
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
    let hStack = HStack(spacing: 20, content: {
        Polygon(numberOfSides: 3)
            .fillColor(.blue)
            .rotationAngle(Angle(degrees: 30))
            .background(lightGray)
        
        Polygon(numberOfSides: 4)
            .fillColor(.blue)
            .rotationAngle(Angle(degrees: 45))
            .background(lightGray)
        
        Polygon(numberOfSides: 5)
            .fillColor(.blue)
            .rotationAngle(Angle(degrees: -18))
            .background(lightGray)
      
        Polygon(numberOfSides: 6)
            .fillColor(.blue)
            .rotationAngle(Angle(degrees: 0))
            .background(lightGray)
    })
    .frame(maxHeight: 360)
    .padding()
    
    return hStack
}
