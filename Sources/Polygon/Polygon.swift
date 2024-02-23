//
//  Polygon.swift
//
//
//  Created by eclypse on 2/22/24.
//

import UIKit

@IBDesignable
open class Polygon: UIView, EquilateralPolygon {
    @IBInspectable open var showDashes: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var fillColor: UIColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var borderColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable open var borderWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable open var numberOfSides: Int = 4 {
        didSet {
            if numberOfSides < 3 {
                numberOfSides = 3
            } else if numberOfSides > 120 {
                numberOfSides = 120
            }
            setNeedsDisplay()
        }
    }
    
    /// Rotation angle expressed in degrees, i.e. 45° or 120°
    @IBInspectable open var rotationAngle: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open func draw(_ rect: CGRect) {
        guard numberOfSides > 2 else { return }
        
        // we need to calculate the middle point of our frame
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        // the polygon points will be located on a circle - hence the radius calculation
        // this radius calculation also takes into account the border width which gets
        // added on the outside of the shape
        let radius = min(rect.width, rect.height) / 2.0 - borderWidth / 2.0
        
        drawDashes(rect: rect, center: centerPoint, radius: radius)
        
        // Apply the rotation transformation to the path
        let polygonPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)
        
        // rotate the polygon based on provided rotation angle
        rotate(polygonPath: polygonPath, originalCenter: centerPoint)
        
        // scale the polygon to fit the bounds
        scale(polygonPath: polygonPath, rect: rect, originalCenter: centerPoint)
        
        // apply colors and border
        fillColor.setFill()
        polygonPath.fill()

        borderColor.setStroke()
        polygonPath.lineWidth = borderWidth
        polygonPath.stroke()
    }
}
