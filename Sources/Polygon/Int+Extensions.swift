//
//  Int+Extensions.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/7/24.
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
