//
//  EquilateralTriangle.swift
//  
//
//  Created by eclypse on 3/21/24.
//

import Foundation

public struct EquilateralTriangle: TileablePolygonKind {
    public var hasEquilateralSides: Bool {
        return true
    }
    
    public var id: String {
        return "EquilateralTriangle-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// triangle has 3 sides. hard coded.
    public let numberOfSides: Int
    
    /// a rotation of 30 degrees allows the EquilateralTriangle to point upwards
    public let initialRotation: CommonAngle
    
    /// initial rotation expressed in degrees
    public init(initialRotation: CGFloat = 30) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 3
    }
}
