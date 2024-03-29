//
//  Int+Extensions.swift
//
//
//  Created by eclypse on 3/7/24.
//

import Foundation

extension Int {
    @inlinable func isEven() -> Bool {
        return self % 2 == 0
    }
    
    @inlinable func isOdd() -> Bool {
        return !isEven()
    }
}

extension CGFloat {
    @inlinable var roundX: CGFloat {
        ((self * 100.0).rounded()) / 100.0
    }
}
