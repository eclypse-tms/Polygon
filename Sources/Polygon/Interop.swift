//
//  UIKit+SwitUI+Interop.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/10/24.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
public typealias BezierPath = Path
#elseif canImport(UIKit)
import UIKit
public typealias BezierPath = UIBezierPath

extension UIBezierPath {
    var boundingRect: CGRect {
        return self.bounds
    }
}

#endif


