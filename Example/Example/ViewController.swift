//
//  ViewController.swift
//  Example
//
//  Created by Nessa Kucuk, Turker on 2/22/24.
//

import UIKit
import Polygon

class ViewController: UIViewController {
    var mainStackView: UIStackView!
    private var constraintsMap = [UIView: ConstraintPair]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
    }

    private func configureUI() {
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.backgroundColor = .systemBackground
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
                
        let bottomStackView = UIStackView()
        bottomStackView.axis = .horizontal
        bottomStackView.backgroundColor = .systemBackground
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
        
        mainStackView = UIStackView()
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .vertical
        mainStackView.backgroundColor = .systemBackground
        mainStackView.alignment = .fill
        mainStackView.spacing = 16
        
        let topPaddingView = UIView()
        let bottomPaddingView = UIView()
        
        mainStackView.addArrangedSubview(topPaddingView)
        mainStackView.addArrangedSubview(topStackView)
        mainStackView.addArrangedSubview(bottomStackView)
        mainStackView.addArrangedSubview(bottomPaddingView)
        
        NSLayoutConstraint.activate([
            topPaddingView.heightAnchor.constraint(equalTo: bottomPaddingView.heightAnchor),
            topPaddingView.widthAnchor.constraint(equalTo: bottomPaddingView.widthAnchor)
        ])
        
        self.view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
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
                polygon.setNeedsLayout()
            }
        }, completion: { [weak self] context in
            guard let strongSelf = self else { return }
            strongSelf.constraintsMap.forEach { (polygon, constraintPair) in
                polygon.setNeedsDisplay()
            }
            strongSelf.mainStackView?.setNeedsLayout()
        })
    }
    
    /// before adding the view to the stack, creates a medium priority height and width constraints
    func addConstrainedSubview(_ aPolygon: Polygon, to stackView: UIStackView) {
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

