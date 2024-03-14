//
//  DemoData.swift
//  Example-UIKit
//
//  Created by Nessa Kucuk, Turker on 3/14/24.
//

import UIKit

enum TileablePolygonType: String, CaseIterable, Identifiable {
    case equilateralTriangle
    case square
    case hexagon
    case octagon
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
    
    var associatedPalette: [UIColor] {
        switch self {
        case .viridis:
            UIColor.viridisPalette
        case .magma:
            UIColor.magmaPalette
        case .inferno:
            UIColor.infernoPalette
        case .plasma:
            UIColor.plasmaPalette
        case .rainbow:
            UIColor.rainbowPalette
        }
    }
}
