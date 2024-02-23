//
//  Polygon.swift
//
//
//  Created by eclypse on 2/22/24.
//

import UIKit

@IBDesignable
open class AnimatablePolygon: UIView, EquilateralPolygon {
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    open func commonInit() {
        guard numberOfSides > 2 else { return }

        // we need to calculate the middle point of our frame
        // we will use this center as an anchor to draw our polygon
        let centerPoint = CGPoint(x: frame.midX, y: frame.midY)

        // the polygon points will be located on a circle - hence the radius calculation
        // this radius calculation also takes into account the border width which gets
        // added on the outside of the shape
        let radius = min(frame.width, frame.height) / 2.0 - borderWidth / 2.0

        drawDashes(rect: frame, center: centerPoint, radius: radius)

        // Apply the rotation transformation to the path
        let polygonPath = drawInitialPolygonPath(centerPoint: centerPoint, radius: radius)

        // rotate the polygon based on provided rotation angle
        rotate(polygonPath: polygonPath, originalCenter: centerPoint)

        // scale the polygon to fit the bounds
        scale(polygonPath: polygonPath, rect: frame, originalCenter: centerPoint)
        
        let shapeLayer = CAShapeLayer(layer: layer)
        shapeLayer.path = polygonPath.cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.masksToBounds = true
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.lineWidth = borderWidth
        self.layer.mask = shapeLayer
    }
}
