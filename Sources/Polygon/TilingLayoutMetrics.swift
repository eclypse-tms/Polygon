//
//  TilingLayoutMetrics.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/8/24.
//

import Foundation

/// Holds information on where to lay out each tile on a canvas
public struct TilingLayoutMetrics {
    /// the point where the tile should be laid out on the X dimension
    public let tileXOffset: CGFloat
    
    /// the point where the tile should be laid out on the Y dimension
    public let tileYOffset: CGFloat
    
    /// shape rotation in radians
    public let initialShapeRotation: CGFloat
    
    /// stagger effect from the shape parameters
    public let appliedStaggerEffect: CGFloat
}
