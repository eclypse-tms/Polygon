//
//  TilablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import SwiftUI

public protocol TilablePolygonKind {
    var numberOfSides: Int { get }
    var initialRotation: Angle { get }
    var staggerEffect: CGFloat { get }
}

public struct EquilateralTriangle: TilablePolygonKind {
    /// triangle has 3 sides. hard coded.
    public let numberOfSides: Int
    
    /// optional. provide a positive value to stagger triangles
    /// when tiling them.
    public let staggerEffect: CGFloat
    
    /// a rotation of 30 degrees allows the EquilateralTriangle to point upwards
    public let initialRotation: Angle
    
    public init(yAxisStagger: CGFloat = 0, initialRotation: CGFloat = 30) {
        self.staggerEffect = yAxisStagger
        self.initialRotation = Angle(degrees: initialRotation)
        self.numberOfSides = 3
    }
}

public struct Square: TilablePolygonKind {
    /// square has 4 sides. hard coded.
    public let numberOfSides: Int
    
    /// optional. provide a positive value to stagger squares
    /// when tiling them.
    public let staggerEffect: CGFloat
    
    /// this allows the Square to look like a square as opposed to diamond
    public let initialRotation: Angle
    
    public init(yAxisStagger: CGFloat = 0, initialRotation: CGFloat = 45) {
        self.staggerEffect = yAxisStagger
        self.initialRotation = Angle(degrees: initialRotation)
        self.numberOfSides = 4
    }
}

public struct Hexagon: TilablePolygonKind {
    /// hexagons have 6 sides. hard coded.
    public let numberOfSides: Int
    
    /// custom hexagon staggering is not supported at the moment
    public let staggerEffect: CGFloat
    
    /// hexagon does not need initial rotation to look right
    public let initialRotation: Angle
    
    public init(initialRotation: CGFloat = 0) {
        self.staggerEffect = 0
        self.initialRotation = Angle(degrees: initialRotation)
        self.numberOfSides = 6
    }
}
