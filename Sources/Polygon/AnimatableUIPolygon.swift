//
//  AnimatableUIPolygon.swift
//
//
//  Created by eclypse on 2/22/24.
//

#if canImport(UIKit)
import UIKit

@IBDesignable
open class AnimatableUIPolygon: UIView, PolygonProtocol {
    open var animationCompletionListener: ((Bool) -> Void)?
    
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
    
    
    /// convience function to apply a basic animation to the polygon sublayer.
    ///
    /// Instead of calling this function, you can get a hold of the CALayer directly
    /// by invoking [AnimatableUIPolygon.polygonLayer].
    /// - Parameters:
    ///   - animation: animation to use for the polygon layer
    ///   - completion: optional callback when the animation is finished
    open func apply(animation: CABasicAnimation, completion: ((Bool) -> Void)? = nil) {
        animation.delegate = self
        animationCompletionListener = completion
        self.polygonLayer?.add(animation, forKey: animation.keyPath)
    }
    
    open var polygonLayer: CAShapeLayer!
    
    open func configurePolygon() {
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

        // scale the polygon to fit the bounds
        scale(polygonPath: polygonPath, rect: bounds, originalCenter: centerPoint, reCenter: true)
        
        let shapePath = CAShapeLayer()
        shapePath.path = polygonPath.cgPath
        shapePath.frame = self.bounds
        shapePath.masksToBounds = true
        shapePath.fillColor = fillColor.cgColor
        shapePath.strokeColor = borderColor.cgColor
        shapePath.lineWidth = borderWidth
        self.layer.addSublayer(shapePath)
        self.polygonLayer?.removeFromSuperlayer()
        self.polygonLayer = shapePath
    }
}

extension AnimatableUIPolygon: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationCompletionListener?(flag)
        animationCompletionListener = nil
    }
}
#elseif canImport(AppKit)
import AppKit
open class AnimatableUIPolygon {
    // this class doesn't do anything in AppKit
}

#endif
