//
//  TilablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import SwiftUI

public enum TilablePolygonKind {
    case equilateralTriangle
    case square
    case hexagon
    
    public var numberOfSides: Int {
        switch self {
        case .equilateralTriangle: return 3
        case .square: return 4
        case .hexagon: return 6
        }
    }
    
    public var defaultRotation: Angle {
        switch self {
        case .equilateralTriangle: return Angle(degrees: 30)
        case .square: return Angle(degrees: 45)
        case .hexagon: return Angle(degrees: 0)
        }
    }
}
