//
//  CommonBezierPath.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/21/24.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(UIKit)
import UIKit
#endif

public struct CommonBezierPath {
    
    #if canImport(SwiftUI)
    public init(with path: Path) {
        self.path = path
        #if canImport(UIKit)
        self.bezierPath = UIBezierPath()
        #endif
    }
    #endif
    
    
    public init() {
        self.path = Path()
        #if canImport(UIKit)
        self.bezierPath = UIBezierPath()
        #endif
    }
    
    public var path: Path
    #if canImport(UIKit)
    public var bezierPath: UIBezierPath
    #endif
    
    public var boundingRect: CGRect {
        #if canImport(SwiftUI)
        path.boundingRect
        #elseif canImport(UIKit)
        bezierPath.bounds
        #endif
    }
    
    public mutating func move(to end: CGPoint) {
        #if canImport(SwiftUI)
        path.move(to: end)
        #elseif canImport(UIKit)
        bezierPath.move(to: end)
        #endif
    }
    
    public mutating func addLine(to end: CGPoint) {
        #if canImport(SwiftUI)
        path.addLine(to: end)
        #elseif canImport(UIKit)
        bezierPath.addLine(to: end)
        #endif
    }
    
    public mutating func closeSubpath() {
        #if canImport(SwiftUI)
        path.closeSubpath()
        #elseif canImport(UIKit)
        bezierPath.close()
        #endif
    }
    
    func transform(_ affineTransform: CGAffineTransform, in rect: CGRect) -> CommonBezierPath {
        #if canImport(SwiftUI)
        return path.transform(affineTransform).path(in: rect).toCommonBezierPath()
        #elseif canImport(UIKit)
        bezierPath.apply(affineTransform)
        return bezierPath
        #endif
    }
}




#if canImport(SwiftUI)
public extension CommonBezierPath {
    
}

public extension Path {
    func toCommonBezierPath() -> CommonBezierPath {
        CommonBezierPath(with: self)
    }
}
#endif



#if canImport(UIKit)
public extension CommonBezierPath {
    
}
#endif
