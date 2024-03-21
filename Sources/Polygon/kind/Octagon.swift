//
//  Octagon.swift
//  
//
//  Created by eclypse on 3/21/24.
//

import Foundation

public struct Octagon: TileablePolygonKind {
    public var id: String {
        return "Octagon-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// octagons have 8 sides. hard coded.
    public let numberOfSides: Int
    
    /// octagons are by default rotated by 22.5° or π/8 so that its left and right
    /// sides are flat
    public let initialRotation: CommonAngle
    
    /// initial rotation expressed in degrees
    public init(initialRotation: CGFloat = 22.5) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 8
    }
}
