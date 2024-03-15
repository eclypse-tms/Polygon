//
//  TileablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import Foundation

public protocol TileablePolygonKind: Hashable, Identifiable {
    var id: String { get }
    var numberOfSides: Int { get }
    var initialRotation: CommonAngle { get }
}

public struct EquilateralTriangle: TileablePolygonKind {
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

public struct Square: TileablePolygonKind {
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
