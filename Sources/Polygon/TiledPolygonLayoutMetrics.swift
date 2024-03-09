//
//  TiledPolygonLayoutMetrics.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/8/24.
//

import SwiftUI

struct TiledPolygonLayoutMetrics {
    /// the point where the tile should be laid out on the X dimension
    let tileXOffset: CGFloat
    
    /// the point where the tile should be laid out on the Y dimension
    let tileYOffset: CGFloat
    
    /// shape rotation in radians
    let initialShapeRotation: CGFloat
    
    /// stagger effect from the shape parameters
    let appliedStaggerEffect: CGFloat
}
