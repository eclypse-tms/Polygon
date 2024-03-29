//
//  TilingLayoutMetrics.swift
//
//
//  Created by eclypse on 3/8/24.
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
    
    /// this tile's bounding rectangle
    public let boundingRect: CGRect
    
    /// whether this tile is laid out completely out of enclosing canvas' bounds.
    /// when a tile is completely out of bounds, it is not visible in the given frame
    public let isOutOfBounds: Bool
    
    /// center of this tile
    public let centerPoint: CGPoint
    
    /// radius of a tight fitting circle
    public let radius: CGFloat
}
