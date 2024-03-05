//
//  TilablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import Foundation

public enum TilablePolygonKind: Int {
    case equilateralTriangle
    case square
    case hexagon
    
    var numberOfSides: Int {
        switch self {
        case .equilateralTriangle: return 3
        case .square: return 4
        case .hexagon: return 6
        }
    }
}
