//
//  UIPolygonProtocol.swift
//  
//
//  Created by eclypse on 3/2/24.
//

#if canImport(UIKit)
import UIKit

public protocol UIPolygonProtocol: UIView {
    /// whether to show dashes around the circle that the initial
    /// polygon is rendered before scaling and rotation. used in the
    /// accompanying blog for demonstration purposes.
    var showDashes: Bool { get set }
    
    /// the color to fill the polygon with
    var fillColor: UIColor { get set }
    
    /// optional border color. only works when the border width is greater than 0
    var borderColor: UIColor { get set }
    
    /// optional border width. specify zero to negate the border
    var borderWidth: CGFloat { get set }
    
    /// number of equal sides
    var numberOfSides: Int { get set }
    
    /// Rotation angle expressed in degrees, i.e. 45° or 120°
    var rotationAngle: CGFloat { get set }
    
    /// expressed in degrees.
    ///
    /// one interior angle of a regular polygon is (numberOfSides -2)*180/numberOfSides
    var oneInteriorAngle: CGFloat { get }
}

public extension UIPolygonProtocol {
    
    var oneInteriorAngle: CGFloat {
        if numberOfSides < 3 {
            return .zero
        } else {
            return CGFloat((numberOfSides - 2)*180)/CGFloat(numberOfSides)
        }
    }
    
    func drawDashes(rect: CGRect, center: CGPoint, radius: CGFloat) {
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
#endif
