//
//  BezierPath.swift
//
//
//  Created by eclypse on 3/21/24.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(UIKit)
import UIKit
#endif


/// A bridging class between UIBezierPath in UIKit and Path in SwiftUI that allows
/// UIKit to draw
public struct BezierPath {
    
    public var path: Path
    
    @inlinable
    public var cgPath: CGPath {
        path.cgPath
    }
    
    @inlinable
    public init() {
        self.path = Path()
    }
    
    @inlinable
    public var boundingRect: CGRect {
        path.boundingRect
    }
    
    @inlinable
    public mutating func move(to end: CGPoint) {
        path.move(to: end)
    }
    
    @inlinable
    public mutating func addLine(to end: CGPoint) {
        path.addLine(to: end)
    }
    
    @inlinable
    public mutating func closeSubpath() {
        path.closeSubpath()
    }
    
    @inlinable
    func transform(_ affineTransform: CGAffineTransform, in rect: CGRect) -> BezierPath {
        return path.transform(affineTransform).path(in: rect).toBezierPath()
    }
}


#if canImport(SwiftUI)
public extension BezierPath {
    @inlinable
    init(with another: Path) {
        self.path = another
    }
}

public extension Path {
    @inlinable
    func toBezierPath() -> BezierPath {
        BezierPath(with: self)
    }
}
#endif


#if canImport(UIKit)
public extension BezierPath {
    @inlinable
    func asUIBezierPath() -> UIBezierPath {
        return UIBezierPath(cgPath: self.path.cgPath)
    }
}
#endif
