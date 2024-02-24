//
//  ViewController.swift
//  Example
//
//  Created by Nessa Kucuk, Turker on 2/22/24.
//

import UIKit
import Polygon

class ViewController: UIViewController {
    private var mainStackView: UIStackView!
    private var topPaddingView: UIView!
    private var bottomPaddingView: UIView!
    private var animatablePolygon: AnimatablePolygon!
    private var constraintsMap = [UIView: ConstraintPair]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureMainView()
        configureTopPadding()
        configureTopStackView()
        configureBottomStack()
        configureSeparator()
        configureAnimatablePolygon()
        configureBottomPadding()
    }
    
    private func configureMainView() {
        mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.backgroundColor = .systemBackground
        mainStackView.alignment = .fill
        mainStackView.spacing = 16
        
        self.view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
        ])
    }
    
    private func configureTopPadding() {
        topPaddingView = UIView()
        mainStackView.addArrangedSubview(topPaddingView)
    }
    
    private func configureTopStackView() {
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
        topStackView.distribution = .equalSpacing
        
        let triangle = Polygon()
        triangle.backgroundColor = .systemGray5
        triangle.fillColor = UIColor.tintColor
        triangle.numberOfSides = 3
        triangle.rotationAngle = 30
        addConstrainedSubview(triangle, to: topStackView)
        
        let rectangle = Polygon()
        rectangle.backgroundColor = .systemGray5
        rectangle.fillColor = UIColor.tintColor
        rectangle.numberOfSides = 4
        rectangle.rotationAngle = 45
        addConstrainedSubview(rectangle, to: topStackView)
        
        let pentagon = Polygon()
        pentagon.backgroundColor = .systemGray5
        pentagon.fillColor = UIColor.tintColor
        pentagon.numberOfSides = 5
        pentagon.rotationAngle = -18
        addConstrainedSubview(pentagon, to: topStackView)
        
        let hexagon = Polygon()
        hexagon.backgroundColor = .systemGray5
        hexagon.fillColor = UIColor.tintColor
        hexagon.numberOfSides = 6
        addConstrainedSubview(hexagon, to: topStackView)
        
        let septagon = Polygon()
        septagon.backgroundColor = .systemGray5
        septagon.fillColor = UIColor.tintColor
        septagon.numberOfSides = 7
        septagon.rotationAngle = -90
        addConstrainedSubview(septagon, to: topStackView)
        
        let octagon = Polygon()
        octagon.backgroundColor = .systemGray5
        octagon.fillColor = UIColor.tintColor
        octagon.numberOfSides = 8
        addConstrainedSubview(octagon, to: topStackView)
        
        let nanogon = Polygon()
        nanogon.backgroundColor = .systemGray5
        nanogon.fillColor = UIColor.tintColor
        nanogon.numberOfSides = 9
        nanogon.rotationAngle = -10.5
        addConstrainedSubview(nanogon, to: topStackView)
        mainStackView.addArrangedSubview(topStackView)
    }
    
    private func configureBottomStack() {
        let bottomStackView = UIStackView()
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .equalSpacing
        
        let tengon = Polygon()
        tengon.backgroundColor = .systemGray5
        tengon.fillColor = UIColor.tintColor
        tengon.numberOfSides = 10
        addConstrainedSubview(tengon, to: bottomStackView)
        
        let elevengon = Polygon()
        elevengon.backgroundColor = .systemGray5
        elevengon.fillColor = UIColor.tintColor
        elevengon.numberOfSides = 11
        addConstrainedSubview(elevengon, to: bottomStackView)
        
        let twelvegon = Polygon()
        twelvegon.backgroundColor = .systemGray5
        twelvegon.fillColor = UIColor.tintColor
        twelvegon.numberOfSides = 12
        addConstrainedSubview(twelvegon, to: bottomStackView)
        
        let thirteengon = Polygon()
        thirteengon.backgroundColor = .systemGray5
        thirteengon.fillColor = UIColor.tintColor
        thirteengon.numberOfSides = 13
        addConstrainedSubview(thirteengon, to: bottomStackView)
        
        let fourteengon = Polygon()
        fourteengon.backgroundColor = .systemGray5
        fourteengon.fillColor = UIColor.tintColor
        fourteengon.numberOfSides = 14
        addConstrainedSubview(fourteengon, to: bottomStackView)
        
        let fifteengon = Polygon()
        fifteengon.backgroundColor = .systemGray5
        fifteengon.fillColor = UIColor.tintColor
        fifteengon.numberOfSides = 15
        addConstrainedSubview(fifteengon, to: bottomStackView)
        
        let sixteengon = Polygon()
        sixteengon.backgroundColor = .systemGray5
        sixteengon.fillColor = UIColor.tintColor
        sixteengon.numberOfSides = 16
        addConstrainedSubview(sixteengon, to: bottomStackView)
        mainStackView.addArrangedSubview(bottomStackView)
    }
    
    private func configureSeparator() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .systemGray3
        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        mainStackView.addArrangedSubview(separatorLine)
    }

    private func configureAnimatablePolygon() {
        let animationStack = UIStackView()
        animationStack.axis = .horizontal
        animationStack.alignment = .center
        animationStack.distribution = .fill
        animationStack.spacing = 16
        
        let button = UIButton(configuration: UIButton.Configuration.filled())
        button.setTitle("Rotate", for: .normal)
        button.addTarget(self, action: #selector(didClickRotate(_:)), for: .touchUpInside)
        animationStack.addArrangedSubview(button)
        
        animatablePolygon = AnimatablePolygon()
        animatablePolygon.backgroundColor = .systemGray5
        animatablePolygon.fillColor = UIColor.systemPurple
        animatablePolygon.numberOfSides = 5
        animatablePolygon.rotationAngle = -18
        addConstrainedSubview(animatablePolygon, to: animationStack)
        
        let paddingView = UIView()
        animationStack.addArrangedSubview(paddingView)
        
        mainStackView.addArrangedSubview(animationStack)
    }
    
    private func configureBottomPadding() {
        bottomPaddingView = UIView()
        mainStackView.addArrangedSubview(bottomPaddingView)
        
        NSLayoutConstraint.activate([
            topPaddingView.heightAnchor.constraint(equalTo: bottomPaddingView.heightAnchor),
            topPaddingView.widthAnchor.constraint(equalTo: bottomPaddingView.widthAnchor)
        ])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let mainStackViewPadding = 32.0
        let paddingBetweenShapes = 16.0 * 6.0
        let idealWidthOfEachPolygon = (size.width - (mainStackViewPadding + paddingBetweenShapes)) / 7.0
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else { return }
            strongSelf.constraintsMap.forEach { (polygon, constraintPair) in
                constraintPair.width.constant = idealWidthOfEachPolygon
            }
            //strongSelf.mainStackView?.setNeedsLayout()
        }, completion: { [weak self] context in
            guard let strongSelf = self else { return }
            strongSelf.mainStackView?.setNeedsLayout()
        })
    }
    
    /// before adding the view to the stack, creates a medium priority height and width constraints
    func addConstrainedSubview(_ aPolygon: EquilateralPolygon, to stackView: UIStackView) {
        let additionalHeight: CGFloat
        switch traitCollection.horizontalSizeClass {
        case .regular:
            additionalHeight = 40
        default:
            additionalHeight = 0
        }
        let primaryViewSize = self.view.bounds.size
        let mainStackViewPadding = 32.0
        let paddingBetweenShapes = 16.0 * 6.0
        let idealWidthOfEachPolygon = (primaryViewSize.width - (mainStackViewPadding + paddingBetweenShapes)) / 7.0
        
        let widthConstraint = aPolygon.widthAnchor.constraint(equalToConstant: idealWidthOfEachPolygon)
        widthConstraint.priority = UILayoutPriority.defaultHigh
        widthConstraint.isActive = true
        
        
        let idealHeightOfEachPolygon = ((primaryViewSize.height - (mainStackViewPadding + paddingBetweenShapes)) / 7.0) + additionalHeight
        
        let heightConstraint = aPolygon.heightAnchor.constraint(equalToConstant: idealHeightOfEachPolygon)
        heightConstraint.priority = UILayoutPriority.defaultHigh
        heightConstraint.isActive = true
        
        constraintsMap[aPolygon] = ConstraintPair(width: widthConstraint, height: heightConstraint)
        stackView.addArrangedSubview(aPolygon)
    }
    
    @objc
    private func didClickRotate(_ sender: Any) {
        //get starting angle (in radians)
        let currentAngleInDegrees = animatablePolygon.rotationAngle
        let amountOfRotation = CGFloat(180)
        let angleAfterRotationInDegrees = currentAngleInDegrees + amountOfRotation
        
        let currentAffineTransform = animatablePolygon.transform
        let newAffineTransform = CGAffineTransform(rotationAngle: amountOfRotation.toRadians())
        
        let basicAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
        basicAnimation.fromValue = CATransform3DMakeAffineTransform(animatablePolygon.transform)
        basicAnimation.toValue = CATransform3DMakeAffineTransform(newAffineTransform)
        basicAnimation.duration = 1 // Animation duration in seconds
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        self.animatablePolygon.apply(animation: basicAnimation)
    }
    
    // Function to rotate around a center point
    func rotate(view: UIView, with angle: CGFloat) -> CGAffineTransform {
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let rotationTransform = CGAffineTransform(rotationAngle: angle)
            //.translatedBy(x: -center.x, y: -center.y)
        
        return rotationTransform
    }
}

struct ConstraintPair {
    let width: NSLayoutConstraint
    let height: NSLayoutConstraint
}


// uncomment to enable preview for iOS > 17
/*
#Preview {
    let aStackView = UIStackView()
    aStackView.axis = .horizontal
    aStackView.backgroundColor = .systemBackground
    aStackView.alignment = .center
    aStackView.spacing = 20
    
    let paddingView = UIView()
    NSLayoutConstraint.activate([
        paddingView.widthAnchor.constraint(equalToConstant: 30)
    ])
    aStackView.addArrangedSubview(paddingView)
    
    let triangle = Polygon()
    triangle.backgroundColor = .systemGray5
    triangle.fillColor = UIColor.tintColor
    triangle.numberOfSides = 3
    triangle.rotationAngle = 30
    NSLayoutConstraint.activate([
        triangle.widthAnchor.constraint(equalToConstant: 150),
        triangle.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(triangle)
    
    let rectangle = Polygon()
    rectangle.backgroundColor = .systemGray5
    rectangle.fillColor = UIColor.tintColor
    rectangle.numberOfSides = 4
    rectangle.rotationAngle = 45
    NSLayoutConstraint.activate([
        rectangle.widthAnchor.constraint(equalToConstant: 150),
        rectangle.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(rectangle)
    
    let pentagon = Polygon()
    pentagon.backgroundColor = .systemGray5
    pentagon.fillColor = UIColor.tintColor
    pentagon.numberOfSides = 5
    pentagon.rotationAngle = -18
    NSLayoutConstraint.activate([
        pentagon.widthAnchor.constraint(equalToConstant: 150),
        pentagon.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(pentagon)
    
    let hexagon = Polygon()
    hexagon.backgroundColor = .systemGray5
    hexagon.fillColor = UIColor.tintColor
    hexagon.numberOfSides = 6
    //rectangle.rotationAngle = 45
    NSLayoutConstraint.activate([
        hexagon.widthAnchor.constraint(equalToConstant: 150),
        hexagon.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(hexagon)
    
    let emptyView = UIView()
    emptyView.setContentCompressionResistancePriority(UILayoutPriority(740), for: .horizontal)
    emptyView.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
    aStackView.addArrangedSubview(emptyView)
    
    return aStackView
}
*/
