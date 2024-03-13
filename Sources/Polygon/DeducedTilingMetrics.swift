//
//  DeducedTilingMetrics.swift
//  
//
//  Created by eclypse on 3/8/24.
//

import Foundation

/// Simple data class that holds information about how many
/// tiles can be placed in a given canvas
public struct DeducedTilingMetrics {
    public let numberOfTileableColumns: Int
    public let numberOfTileableRows: Int
    
    /// calculated tile size
    public let effectiveTileSize: CGSize
}
