//
//  Polygon.swift
//
//
//  Created by eclypse on 2/22/24.
//

import UIKit

@IBDesignable
open class AnimatablePolygon: UIView, EquilateralPolygon {
    open var animationCompletionListener: (() -> Void)?
    
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
    
    @IBInspectable open var rotationAngle: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        configurePolygon()
    }
    
    open func apply(animation: CABasicAnimation, completion: (() -> Void)? = nil) {
        animation.delegate = self
        animationCompletionListener = completion
        self.polygonLayer?.add(animation, forKey: animation.keyPath)
    }
    
    open var polygonLayer: CAShapeLayer?
    
    open func configurePolygon() {
        polygonLayer?.removeFromSuperlayer()
        polygonLayer == nil
        
        
        guard numberOfSides > 2 else { return }

        // we need to calculate the middle point of our frame
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        // the polygon points will be located on a circle - hence the radius calculation
        // this radius calculation also takes into account the border width which gets
        // added on the outside of the shape
        let radius = min(bounds.width, bounds.height) / 2.0 - borderWidth / 2.0

        drawDashes(rect: bounds, center: centerPoint, radius: radius)

        // Apply the rotation transformation to the path
        let polygonPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)

        // rotate the polygon based on provided rotation angle
        rotate(polygonPath: polygonPath, originalCenter: centerPoint)

        // scale the polygon to fit the bounds
        scale(polygonPath: polygonPath, rect: bounds, originalCenter: centerPoint)
        
        let shapePath = CAShapeLayer()
        shapePath.path = polygonPath.cgPath
        shapePath.frame = self.bounds
        shapePath.masksToBounds = true
        shapePath.fillColor = fillColor.cgColor
        shapePath.strokeColor = borderColor.cgColor
        shapePath.lineWidth = borderWidth
        self.layer.addSublayer(shapePath)
        self.polygonLayer = shapePath
    }
}

extension AnimatablePolygon: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationCompletionListener?()
        animationCompletionListener = nil
    }
}
