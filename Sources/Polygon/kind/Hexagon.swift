//
//  Hexagon.swift
//  
//
//  Created by eclypse on 3/21/24.
//

import Foundation

public struct Hexagon: TileablePolygonKind {
    public var id: String {
        return "Hexagon-numberOfSides:\(numberOfSides)-rotation:\(initialRotation.degrees)"
    }
    /// hexagons have 6 sides. hard coded.
    public let numberOfSides: Int
    
    /// hexagon does not need initial rotation to look right
    public let initialRotation: CommonAngle
    
    /// initial rotation expressed in degrees
    public init(initialRotation: CGFloat = 0) {
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 6
    }
}
