//
//  Quadgon.swift
//
//
//  Created by eclypse on 3/21/24.
//

import Foundation

/// Quadgon name is chosen due to SwiftUI's type conflict. It is just a rectangle.
public struct Quadgon: TileablePolygonKind {
    public var hasEquilateralSides: Bool {
        return false
    }
    
    public var id: String {
        return "Rectangle-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// square has 4 sides. hard coded.
    public let numberOfSides: Int
    
    /// this allows the Rectangle to look like a rectangle, as opposed to a diamond
    public let initialRotation: CommonAngle
    
    /// provide a ratio where the width is the numerator and the height is the denominator,
    /// i.e: W/H
    public let widthToHeightRatio: CGFloat
    
    /// initial rotation expressed in degrees
    public init(widthToHeightRatio: CGFloat, initialRotation: CGFloat = 45) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 4
        self.widthToHeightRatio = widthToHeightRatio
    }
}
