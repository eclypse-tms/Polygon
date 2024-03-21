//
//  TileablePolygonKind.swift
//
//
//  Created by eclypse on 3/4/24.
//

import Foundation

public protocol TileablePolygonKind: Hashable, Identifiable {
    var id: String { get }
    var numberOfSides: Int { get }
    var initialRotation: CommonAngle { get }
}
