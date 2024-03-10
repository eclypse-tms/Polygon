//
//  TileablePolygonSize.swift
//  
//
//  Created by eclypse on 3/8/24.
//

import Foundation

/// When you create a TileablePolygonSize, you either provide a fixed width or
/// number of polygons that should be placed horizontally in a row.
///
/// When you provide a fixedWidth, then the number of tiled polygons in a row fluctuates.
/// When you provide a target, then the size of each polygon fluctuates.
///
/// - Note: The height of the polygon is not necessary and can be derived from its width.
public struct TileablePolygonSize {
    let fixedWidth: CGFloat
    let horizontalPolygonTarget: CGFloat?
    
    public init(fixedWidth: CGFloat) {
        self.fixedWidth = fixedWidth
        self.horizontalPolygonTarget = nil
    }
    
    public init(horizontalPolygonTarget: CGFloat) {
        self.horizontalPolygonTarget = horizontalPolygonTarget
        self.fixedWidth = 64 //default size not used
    }
}
