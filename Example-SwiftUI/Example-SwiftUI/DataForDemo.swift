//
//  DataForDemo.swift
//  Example-SwiftUI
//
//  Created by eclypse on 3/11/24.
//

import Foundation
import SwiftUI

enum TileablePolygonType: String, CaseIterable, Identifiable {
    case equilateralTriangle
    case square
    case hexagon
    case octagon
    case rectangle
    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .equilateralTriangle:
            return "triangle"
        case .square:
            return "square"
        case .hexagon:
            return "hexagon"
        case .octagon:
            return "octagon"
        case .rectangle:
            return "rectangle"
        }
    }
    
    var displayName: String {
        switch self {
        case .equilateralTriangle:
            return "Equilateral Triangle"
        case .square:
            return "Square"
        case .hexagon:
            return "Hexagon"
        case .octagon:
            return "Octagon"
        case .rectangle:
            return "Rectangle"
        }
    }
}

enum PolygonSize: String, CaseIterable, Identifiable {
    case fixedWidth
    case horizontalTarget
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .fixedWidth:
            return "Fixed Width"
        case .horizontalTarget:
            return "Target"
        }
    }
    
    var defaultWidth: CGFloat {
        switch self {
        case .fixedWidth: return 64
        case .horizontalTarget: return 12
        }
    }
}

enum ColorPalette: String, CaseIterable, Identifiable {
    case viridis, magma, inferno, plasma, rainbow
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .viridis: return "Viridis"
        case .magma: return "Magma"
        case .inferno: return "Inferno"
        case .plasma: return "Plasma"
        case .rainbow: return "Rainbow"
        }
    }
    
    var associatedPalette: [Color] {
        switch self {
        case .viridis:
            Color.viridisPalette
        case .magma:
            Color.magmaPalette
        case .inferno:
            Color.infernoPalette
        case .plasma:
            Color.plasmaPalette
        case .rainbow:
            Color.rainbowPalette
        }
    }
}

