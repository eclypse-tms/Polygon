//
//  ViewController.swift
//  Example-UIKit
//
//  Created by eclypse on 3/13/24.
//

import UIKit
import Polygon

class ViewController: UIViewController {
    @IBOutlet private var mainStackView: UIStackView!
    @IBOutlet private var polygonSelectorSegment: UISegmentedControl!
    @IBOutlet private var individualPolygonsStackView: UIStackView!
    @IBOutlet private var tiledPolygon: UITiledPolygon!
    @IBOutlet private var tiledPolygonControlPanel: UIView!
    @IBOutlet private var selectPolygonKind: UIButton!
    @IBOutlet private var sizeSelectorSegment: UISegmentedControl!
    @IBOutlet private var fixedWidthSizeText: UITextField!
    @IBOutlet private var targetSizeText: UITextField!
    @IBOutlet private var tilePaddingSlider: UISlider!
    @IBOutlet private var tilePaddingLabel: UILabel!
    @IBOutlet private var singleOrMultiColorSelection: UISegmentedControl!
    @IBOutlet private var colorPicker: UIColorWell!
    @IBOutlet private var colorPickerLabel: UILabel!
    @IBOutlet private var palettePicker: UIButton!
    @IBOutlet private var staggerEffectSlider: UISlider!
    @IBOutlet private var staggerEffectLabel: UILabel!
    @IBOutlet private var pickAColorLabel: UILabel!
    @IBOutlet private var staggerControls: UIStackView!
    
    private var topPaddingView: UIView!
    private var bottomPaddingView: UIView!
    private var animateButton: UIButton!
    private var animatablePolygon: UIPolygon!
    private var constraintsMap = [UIView: ConstraintPair]()
    
    private let percentFormatter = NumberFormatter()
    private var rawInterTilingSpace: Double = 2.0
    private var rawStaggerEffect: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureIndividualPolygons()
        configureTiledPolygon()
        configureTopPadding()
        configureTopStackView()
        configureBottomStack()
        configureSeparator()
        configureAnimatablePolygon()
        configureBottomPadding()
    }
    
    private func configureIndividualPolygons() {
        individualPolygonsStackView.isHidden = true
        
        individualPolygonsStackView.axis = .vertical
        individualPolygonsStackView.backgroundColor = .systemBackground
        individualPolygonsStackView.alignment = .fill
        individualPolygonsStackView.spacing = 16
    }
    
    private func configureTiledPolygon() {
        tiledPolygon.backgroundColor = .systemGray5
        tiledPolygon.isHidden = false //initial condition
        tiledPolygon.polygonSize = TileablePolygonSize(horizontalPolygonTarget: 12)
        tiledPolygon.tileablePolygonKind = Square()
        tiledPolygon.interTileSpacing = 2.0
        
        tiledPolygonControlPanel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        tiledPolygonControlPanel.layer.cornerRadius = 12
        tiledPolygonControlPanel.clipsToBounds = true
        
        // polygon selection
        let polygonTypeMenuOptions = TileablePolygonType.allCases.map { eachType -> UIAction in
            return UIAction(title: eachType.displayName, identifier: UIAction.Identifier(eachType.id.rawValue), handler: { action in
                self.handlePolygonType(action)
            })
        }
        let polygonTypeMenu = UIMenu(children: polygonTypeMenuOptions)
        selectPolygonKind.menu = polygonTypeMenu
        
        // polygon size
        sizeSelectorSegment.selectedSegmentIndex = 1
        fixedWidthSizeText.text = "64" //default value
        targetSizeText.text = "12" //default value
        fixedWidthSizeText.isHidden = true //hide it by default
        
        // inter tile space slider
        tilePaddingSlider.value = 2.0 //default value
        rawInterTilingSpace = 2.0
        
        // single or multi color selector
        singleOrMultiColorSelection.selectedSegmentIndex = 0 //default
        
        // color well
        colorPicker.addTarget(self, action: #selector(didChangeColor(_:)), for: .valueChanged)
        colorPicker.selectedColor = .systemBlue
        colorPickerLabel.text = "Pick a color"
        
        // color palette picker
        let colorPaletteMenuOptions = ColorPalette.allCases.map { eachColorPalette -> UIAction in
            return UIAction(title: eachColorPalette.displayName, identifier: UIAction.Identifier(eachColorPalette.id.rawValue), handler: { action in
                self.handleColorPalette(action)
            })
        }
        let colorPaletteMenu = UIMenu(children: colorPaletteMenuOptions)
        palettePicker.menu = colorPaletteMenu
        palettePicker.isHidden = true //hidden by default
        
        //stagger effect
        staggerEffectSlider.value = 0.0 //default value
        rawStaggerEffect = 0.0
        
        //configure number formatter
        percentFormatter.minimumFractionDigits = 0
        percentFormatter.maximumFractionDigits = 0
        percentFormatter.numberStyle = .percent
    }
    
    @IBAction
    private func didChangeStaggerValue(_ sender: UISlider) {
        let nearestInteger = CGFloat(sender.value.rounded())
        //the value are between 0 and 20. Interpret them as 0 to 100% in 5% increments.
        let percentEquivalent: Double = (nearestInteger * 5.0) / 100.0
        
        if rawStaggerEffect == percentEquivalent {
            //the slider didn't change enough, nothing to do
        } else {
            //the slider changed more than 5% - re-render the polygons
            rawStaggerEffect = percentEquivalent
            let formattedResult = percentFormatter.string(from: NSNumber(floatLiteral: percentEquivalent))
            tiledPolygon.staggerEffect = StaggerEffect(percentEquivalent)
            staggerEffectLabel.text = formattedResult
        }
    }
    
    @objc
    private func didChangeColor(_ sender: UIColorWell) {
        tiledPolygon.fillColor = sender.selectedColor ?? UIColor.tintColor
    }
    
    @IBAction
    private func didChangeTilePadding(_ sender: UISlider) {
        let nearestInteger = CGFloat(sender.value.rounded())
        if rawInterTilingSpace == nearestInteger {
            //the slider didn't change enough, nothing to do
        } else {
            rawInterTilingSpace = nearestInteger
            tiledPolygon.interTileSpacing = nearestInteger
            tilePaddingLabel.text = "\(Int(nearestInteger)) pt"
        }
    }
    
    @IBAction
    private func didChangeSize(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //fixed width
            fixedWidthSizeText.isHidden = false
            targetSizeText.isHidden = true
            let parsedFixedWidthSize = Int(fixedWidthSizeText.text ?? "64") ?? 64
            tiledPolygon.polygonSize = TileablePolygonSize(fixedWidth: CGFloat(parsedFixedWidthSize))
        default: // target size
            fixedWidthSizeText.isHidden = true
            targetSizeText.isHidden = false
            let parsedTargetSize = Int(targetSizeText.text ?? "12") ?? 12
            tiledPolygon.polygonSize = TileablePolygonSize(horizontalPolygonTarget: CGFloat(parsedTargetSize))
        }
    }
    
    @IBAction
    private func didSelectSingleOrMultiColor(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //single color selection
            colorPicker.isHidden = false
            palettePicker.isHidden = true
            tiledPolygon.fillColor = colorPicker.selectedColor ?? UIColor.tintColor
            colorPickerLabel.text = "Pick a color"
        default: // multi color selection
            colorPicker.isHidden = true
            palettePicker.isHidden = false
            tiledPolygon.fillColorPattern = UIColor.viridisPalette
            colorPickerLabel.text = "Pick a palette"
        }
    }
    
    private func handlePolygonType(_ action: UIAction) {
        switch action.identifier.rawValue {
        case TileablePolygonType.equilateralTriangle.id.rawValue:
            tiledPolygon.tileablePolygonKind = EquilateralTriangle()
            staggerControls.isHidden = false
        case TileablePolygonType.square.id.rawValue:
            tiledPolygon.tileablePolygonKind = Square()
            staggerControls.isHidden = false
        case TileablePolygonType.octagon.id.rawValue:
            tiledPolygon.tileablePolygonKind = Octagon()
            staggerControls.isHidden = false
        case TileablePolygonType.hexagon.id.rawValue:
            tiledPolygon.tileablePolygonKind = Hexagon()
            //hexagon cannot be staggered at the moment
            staggerControls.isHidden = true
        default:
            break
        }
    }
    
    private func handleColorPalette(_ action: UIAction) {
        switch action.identifier.rawValue {
        case ColorPalette.viridis.id.rawValue:
            tiledPolygon.fillColorPattern = UIColor.viridisPalette
        case ColorPalette.magma.id.rawValue:
            tiledPolygon.fillColorPattern = UIColor.magmaPalette
        case ColorPalette.inferno.id.rawValue:
            tiledPolygon.fillColorPattern = UIColor.infernoPalette
        case ColorPalette.plasma.id.rawValue:
            tiledPolygon.fillColorPattern = UIColor.plasmaPalette
        case ColorPalette.rainbow.id.rawValue:
            tiledPolygon.fillColorPattern = UIColor.rainbowPalette
        default:
            break
        }
    }
    
    private func configureTopPadding() {
        topPaddingView = UIView()
        individualPolygonsStackView.addArrangedSubview(topPaddingView)
    }
    
    private func configureTopStackView() {
        let topStackView = UIStackView()
        topStackView.axis = .horizontal
        topStackView.alignment = .fill
        topStackView.distribution = .equalSpacing
        
        let triangle = UIPolygon()
        triangle.backgroundColor = .systemGray5
        triangle.fillColor = UIColor.tintColor
        triangle.numberOfSides = 3
        triangle.rotationAngle = 30
        addConstrainedSubview(triangle, to: topStackView)
        
        let rectangle = UIPolygon()
        rectangle.backgroundColor = .systemGray5
        rectangle.fillColor = UIColor.tintColor
        rectangle.numberOfSides = 4
        rectangle.rotationAngle = 45
        addConstrainedSubview(rectangle, to: topStackView)
        
        let pentagon = UIPolygon()
        pentagon.backgroundColor = .systemGray5
        pentagon.fillColor = UIColor.tintColor
        pentagon.numberOfSides = 5
        pentagon.rotationAngle = -18
        addConstrainedSubview(pentagon, to: topStackView)
        
        let hexagon = UIPolygon()
        hexagon.backgroundColor = .systemGray5
        hexagon.fillColor = UIColor.tintColor
        hexagon.numberOfSides = 6
        addConstrainedSubview(hexagon, to: topStackView)
        
        let septagon = UIPolygon()
        septagon.backgroundColor = .systemGray5
        septagon.fillColor = UIColor.tintColor
        septagon.numberOfSides = 7
        septagon.rotationAngle = -90
        addConstrainedSubview(septagon, to: topStackView)
        
        let octagon = UIPolygon()
        octagon.backgroundColor = .systemGray5
        octagon.fillColor = UIColor.tintColor
        octagon.numberOfSides = 8
        addConstrainedSubview(octagon, to: topStackView)
        
        let nanogon = UIPolygon()
        nanogon.backgroundColor = .systemGray5
        nanogon.fillColor = UIColor.tintColor
        nanogon.numberOfSides = 9
        nanogon.rotationAngle = -10.5
        addConstrainedSubview(nanogon, to: topStackView)
        
        individualPolygonsStackView.addArrangedSubview(topStackView)
    }
    
    private func configureBottomStack() {
        let bottomStackView = UIStackView()
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .fill
        bottomStackView.distribution = .equalSpacing
        
        let tengon = UIPolygon()
        tengon.backgroundColor = .systemGray5
        tengon.fillColor = UIColor.tintColor
        tengon.numberOfSides = 10
        addConstrainedSubview(tengon, to: bottomStackView)
        
        let elevengon = UIPolygon()
        elevengon.backgroundColor = .systemGray5
        elevengon.fillColor = UIColor.tintColor
        elevengon.numberOfSides = 11
        addConstrainedSubview(elevengon, to: bottomStackView)
        
        let twelvegon = UIPolygon()
        twelvegon.backgroundColor = .systemGray5
        twelvegon.fillColor = UIColor.tintColor
        twelvegon.numberOfSides = 12
        addConstrainedSubview(twelvegon, to: bottomStackView)
        
        let thirteengon = UIPolygon()
        thirteengon.backgroundColor = .systemGray5
        thirteengon.fillColor = UIColor.tintColor
        thirteengon.numberOfSides = 13
        addConstrainedSubview(thirteengon, to: bottomStackView)
        
        let fourteengon = UIPolygon()
        fourteengon.backgroundColor = .systemGray5
        fourteengon.fillColor = UIColor.tintColor
        fourteengon.numberOfSides = 14
        addConstrainedSubview(fourteengon, to: bottomStackView)
        
        let fifteengon = UIPolygon()
        fifteengon.backgroundColor = .systemGray5
        fifteengon.fillColor = UIColor.tintColor
        fifteengon.numberOfSides = 15
        addConstrainedSubview(fifteengon, to: bottomStackView)
        
        let sixteengon = UIPolygon()
        sixteengon.backgroundColor = .systemGray5
        sixteengon.fillColor = UIColor.tintColor
        sixteengon.numberOfSides = 16
        addConstrainedSubview(sixteengon, to: bottomStackView)
        individualPolygonsStackView.addArrangedSubview(bottomStackView)
    }
    
    private func configureSeparator() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .systemGray3
        NSLayoutConstraint.activate([
            separatorLine.heightAnchor.constraint(equalToConstant: 1.0)
        ])
        individualPolygonsStackView.addArrangedSubview(separatorLine)
    }

    private func configureAnimatablePolygon() {
        let animationStack = UIStackView()
        animationStack.axis = .horizontal
        animationStack.alignment = .center
        animationStack.distribution = .fill
        animationStack.spacing = 16
        
        animateButton = UIButton(configuration: UIButton.Configuration.filled())
        animateButton.setTitle("Animate", for: .normal)
        animateButton.addTarget(self, action: #selector(didClickFadeOrShow(_:)), for: .touchUpInside)
        animationStack.addArrangedSubview(animateButton)
        NSLayoutConstraint.activate([
            animateButton.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        animatablePolygon = UIPolygon()
        animatablePolygon.backgroundColor = .systemGray5
        animatablePolygon.fillColor = UIColor.systemPurple
        animatablePolygon.numberOfSides = 5
        animatablePolygon.rotationAngle = -18
        addConstrainedSubview(animatablePolygon, to: animationStack)
        
        let paddingView = UIView()
        animationStack.addArrangedSubview(paddingView)
        
        individualPolygonsStackView.addArrangedSubview(animationStack)
    }
    
    private func configureBottomPadding() {
        bottomPaddingView = UIView()
        individualPolygonsStackView.addArrangedSubview(bottomPaddingView)
        
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
            strongSelf.individualPolygonsStackView?.setNeedsLayout()
        })
    }
    
    /// before adding the view to the stack, creates a medium priority height and width constraints
    func addConstrainedSubview(_ aPolygon: UIPolygonProtocol, to stackView: UIStackView) {
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
    private func didClickFadeOrShow(_ sender: Any) {
        //get starting angle (in radians)
        let currentOpacity = Float(animatablePolygon.polygonLayer.opacity)
        let targetOpacity = 1.0 - currentOpacity
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = currentOpacity
        opacityAnimation.toValue = targetOpacity
        opacityAnimation.duration = 2.0
        opacityAnimation.isRemovedOnCompletion = false
        opacityAnimation.fillMode = .forwards
        opacityAnimation.repeatCount = 1
        opacityAnimation.autoreverses = true
        
        self.animatablePolygon.apply(animation: opacityAnimation, completion: { _ in
            //self.animatablePolygon.polygonLayer.opacity = targetOpacity
        })
        
        /*
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.fromValue = Float(1.0)
        opacityAnimation.toValue = Float(0.0)
        opacityAnimation.duration = 0.5
        */
    }
    
    @IBAction
    private func didClickSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            individualPolygonsStackView.isHidden = false
            tiledPolygon.isHidden = true
            tiledPolygonControlPanel.isHidden = true
        default:
            individualPolygonsStackView.isHidden = true
            tiledPolygon.isHidden = false
            tiledPolygonControlPanel.isHidden = false
        }
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
    
    let triangle = UIPolygon()
    triangle.backgroundColor = .systemGray5
    triangle.fillColor = UIColor.tintColor
    triangle.numberOfSides = 3
    triangle.rotationAngle = 30
    NSLayoutConstraint.activate([
        triangle.widthAnchor.constraint(equalToConstant: 150),
        triangle.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(triangle)
    
    let rectangle = UIPolygon()
    rectangle.backgroundColor = .systemGray5
    rectangle.fillColor = UIColor.tintColor
    rectangle.numberOfSides = 4
    rectangle.rotationAngle = 45
    NSLayoutConstraint.activate([
        rectangle.widthAnchor.constraint(equalToConstant: 150),
        rectangle.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(rectangle)
    
    let pentagon = UIPolygon()
    pentagon.backgroundColor = .systemGray5
    pentagon.fillColor = UIColor.tintColor
    pentagon.numberOfSides = 5
    pentagon.rotationAngle = -18
    NSLayoutConstraint.activate([
        pentagon.widthAnchor.constraint(equalToConstant: 150),
        pentagon.heightAnchor.constraint(equalToConstant: 180),
    ])
    aStackView.addArrangedSubview(pentagon)
    
    let hexagon = UIPolygon()
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

