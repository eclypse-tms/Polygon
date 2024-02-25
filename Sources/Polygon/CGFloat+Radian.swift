//
//  CGFloat+Radian.swift
//
//
//  Created by eclypse on 2/22/24.
//

import Foundation

extension CGFloat {
    public func toRadians() -> CGFloat {
        return CGFloat.pi * (self/180.0)
    }
}
