//
//  StaggerEffect.swift
//
//
//  Created by eclypse on 3/13/24.
//

import Foundation


/// You can provide a stagger effect when using TiledPolygons so that the next
/// row or column starts with the specified amount of offset when laid out.
///
/// For example: provide 0.5 for an alternate tiling effect.
/// ![Squares are tiled in an alternate fashion](https://i.imgur.com/gZm9o4J.png "alternate tiling")
public struct StaggerEffect: Hashable {
    
    /// Provide a positive value between 0 and 1 to stagger the shapes on their X or Y axis
    /// when tiling them.
    ///
    /// The provided value is interpreted in terms of percentage of the calculated tile height.
    /// Any values outside of the acceptable range are ignored.
    public let amount: CGFloat
    
    /// Can apply the stagger effect only on the y axis at the moment.
    /// Support for x-axis will be offered in the near future.
    public let axis: EffectDimension
    
    /// Initialize a new StaggerEffect with the specified amount and axis
    public init(_ amount: CGFloat, axis: EffectDimension = .yAxis) {
        if amount >= 1.0 {
            self.amount = 0.0
        } else if amount < 0.0 {
            self.amount = 0.0
        } else {
            self.amount = amount
        }
        self.axis = axis
    }
    
    public static var zero: StaggerEffect {
        return StaggerEffect(0.0)
    }
}

/// Determines which dimension to apply a tiling effect. Currently only y axis is supported.
public enum EffectDimension: Int, Hashable {
    /// effect is applied along the y axis in the layout coordinates
    case yAxis
}
