//
//  Rectangle.swift
//
//
//  Created by eclypse on 3/21/24.
//

import Foundation

public struct Rectangle: TileablePolygonKind {
    public var id: String {
        return "Square-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// square has 4 sides. hard coded.
    public let numberOfSides: Int
    
    /// this allows the Rectangle to look like a rectangle, as opposed to a diamond
    public let initialRotation: CommonAngle
    
    /// provide a ratio where the width is the numerator and the height is the denominator
    public let widthToHeightRatio: CGFloat
    
    /// initial rotation expressed in degrees
    public init(widthToHeightRatio: CGFloat, initialRotation: CGFloat = 45) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 4
        self.widthToHeightRatio = widthToHeightRatio
    }
}
