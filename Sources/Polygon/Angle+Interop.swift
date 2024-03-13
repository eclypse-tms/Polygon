//
//  CommonAngle.swift
//
//
//  Created by eclypse on 3/10/24.
//

import Foundation

/// Angle concept similar to that of SwiftUI's
public struct CommonAngle: Hashable, Codable, Sendable {
    public let degrees: CGFloat
    public let radians: CGFloat
    
    public init(degrees: CGFloat) {
        self.degrees = degrees
        self.radians = degrees.toRadians()
    }
    
    public init(radians: CGFloat) {
        self.degrees = radians.toDegrees()
        self.radians = radians
    }
    
    static var zero: CommonAngle {
        return CommonAngle(radians: 0.0)
    }
}

#if canImport(SwiftUI)
import SwiftUI
extension CommonAngle {
    func toAngle() -> Angle {
        return Angle(radians: self.radians)
    }
}
#endif



