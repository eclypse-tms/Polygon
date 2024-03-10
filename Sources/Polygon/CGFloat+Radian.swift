//
//  CGFloat+Radian.swift
//
//
//  Created by eclypse on 2/22/24.
//

import Foundation

extension CGFloat {
    /// converts degrees to radian equivalent
    public func toRadians() -> CGFloat {
        return CGFloat.pi * (self/180.0)
    }
    
    /// converts radians to degree equivalent
    public func toDegrees() -> CGFloat {
        return (self * 180.0) / CGFloat.pi
    }
}
