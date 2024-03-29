//
//  Square.swift
//  
//
//  Created by eclypse on 3/21/24.
//

import Foundation

public struct Square: TileablePolygonKind {
    public var hasEquilateralSides: Bool {
        return true
    }
    
    public var id: String {
        return "Square-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// square has 4 sides. hard coded.
    public let numberOfSides: Int
    
    /// this allows the Square to look like a square as opposed to diamond
    public let initialRotation: CommonAngle
    
    /// initial rotation expressed in degrees
    public init(initialRotation: CGFloat = 45) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 4
    }
}
