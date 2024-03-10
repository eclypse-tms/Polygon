//
//  TileablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import Foundation

public protocol TileablePolygonKind {
    var numberOfSides: Int { get }
    var initialRotation: CommonAngle { get }
    var staggerEffect: CGFloat { get }
    
    /// calculates the base length of a tileable polygon for the provided tile width
    func baseLength(for tileWidth: CGFloat) -> CGFloat
}

public struct EquilateralTriangle: TileablePolygonKind {
    /// triangle has 3 sides. hard coded.
    public let numberOfSides: Int
    
    /// optional. provide a positive value to stagger triangles
    /// when tiling them.
    public let staggerEffect: CGFloat
    
    /// a rotation of 30 degrees allows the EquilateralTriangle to point upwards
    public let initialRotation: CommonAngle
    
    public func baseLength(for tileWidth: CGFloat) -> CGFloat {
        //equilateral triangles take up the entire span of the tile width-wise
        return tileWidth
    }
    
    /// initial rotation expressed in degrees
    public init(yAxisStagger: CGFloat = 0, initialRotation: CGFloat = 30) {
        self.staggerEffect = yAxisStagger
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 3
    }
}

public struct Square: TileablePolygonKind {
    /// square has 4 sides. hard coded.
    public let numberOfSides: Int
    
    /// optional. provide a positive value to stagger squares when tiling them.
    public let staggerEffect: CGFloat
    
    /// this allows the Square to look like a square as opposed to diamond
    public let initialRotation: CommonAngle
    
    public func baseLength(for tileWidth: CGFloat) -> CGFloat {
        //square take up the entire span of the tile width-wise
        return tileWidth
    }
    
    /// initial rotation expressed in degrees
    public init(yAxisStagger: CGFloat = 0, initialRotation: CGFloat = 45) {
        self.staggerEffect = yAxisStagger
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 4
    }
}

public struct Hexagon: TileablePolygonKind {
    /// hexagons have 6 sides. hard coded.
    public let numberOfSides: Int
    
    /// custom hexagon staggering is not supported at the moment
    public let staggerEffect: CGFloat
    
    /// hexagon does not need initial rotation to look right
    public let initialRotation: CommonAngle
    
    public func baseLength(for tileWidth: CGFloat) -> CGFloat {
        //hexagon's base length is equal to the radius of the circle
        //that encompasses it. 2r is the width of the tile; therefore,
        //the hexagon's base length is half of the tile width
        return tileWidth / 2.0
    }
    
    /// initial rotation expressed in degrees
    public init(initialRotation: CGFloat = 0) {
        self.staggerEffect = 0
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 6
    }
}

public struct Octagon: TileablePolygonKind {
    /// octagons have 8 sides. hard coded.
    public let numberOfSides: Int
    
    /// optional. provide a positive value to stagger the shapes when tiling them.
    public let staggerEffect: CGFloat
    
    /// octagons are by default rotated by 22.5° or π/8 so that its left and right
    /// sides are flat
    public let initialRotation: CommonAngle
    
    public func baseLength(for tileWidth: CGFloat) -> CGFloat {
        //let b to be the base length of an octagon
        //then tileWidth = (1 + √2)b
        //re-arranging for -> b = (1 + √2)/tileWidth
        return (1 + sqrt(2))/tileWidth
    }
    
    /// initial rotation expressed in degrees
    public init(yAxisStagger: CGFloat = 0, initialRotation: CGFloat = 22.5) {
        self.staggerEffect = yAxisStagger
        self.initialRotation = CommonAngle(degrees: initialRotation)
        self.numberOfSides = 8
    }
}
