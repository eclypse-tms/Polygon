//
//  FlexibleTiling.swift
//
//
//  Created by eclypse on 3/4/24.
//

import Foundation

/// indicates how many tiles should be placed in horizontally and
/// vertically in any given view container
public struct FlexibleTiling {
    /// indicates the number of tiles that should be placed horizontally.
    /// this number also dictates how many tiles can be placed vertically
    /// depending on how many you can fit horizontally.
    public let numberOfHorizontalTiles: CGFloat
    
    /// optional gap between each tile
    public let interTilingSpace: CGFloat
    
    init(numberOfHorizontalTiles: CGFloat,
         interTilingSpace: CGFloat = .zero) {
        self.numberOfHorizontalTiles = numberOfHorizontalTiles
        self.interTilingSpace = interTilingSpace
    }
}
