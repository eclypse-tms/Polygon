//
//  Color+Hex.swift
//
//
//  Created by Nessa Kucuk, Turker on 3/8/24.
//

import SwiftUI

public extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let length = String(hexSanitized).count
        
        if Scanner(string: hexSanitized).scanHexInt64(&rgb) {
            if length == 6 {
                red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                blue = CGFloat(rgb & 0x0000FF) / 255.0

            } else if length == 8 {
                red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat(rgb & 0x000000FF) / 255.0
            }
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    static var viridisColorPalette: [Color] {
        return [Color(hex: "fde725"),
            Color(hex: "a0da39"),
            Color(hex: "4ac16d"),
            Color(hex: "1fa187"),
            Color(hex: "277f8e"),
            Color(hex: "365c8d"),
            Color(hex: "46327e"),
            Color(hex: "440154")
        ]
    }
    
    static var magmaColorPalette: [Color] {
        return [Color(hex: "fcfdbf"),
            Color(hex: "febb81"),
            Color(hex: "f8765c"),
            Color(hex: "d3436e"),
            Color(hex: "982d80"),
            Color(hex: "5f187f"),
            Color(hex: "221150"),
            Color(hex: "000004")
        ]
    }
    
    static var infernoColorPalette: [Color] {
        return [Color(hex: "fcffa4"),
            Color(hex: "fac228"),
            Color(hex: "f57d15"),
            Color(hex: "d44842"),
            Color(hex: "9f2a63"),
            Color(hex: "65156e"),
            Color(hex: "280b53"),
            Color(hex: "000004")
        ]
    }
    
    var plasmaColorPalette: [Color] {
        return [Color(hex: "f0f921"),
            Color(hex: "#febd2a"),
            Color(hex: "f48849"),
            Color(hex: "db5c68"),
            Color(hex: "b83289"),
            Color(hex: "8b0aa5"),
            Color(hex: "5302a3"),
            Color(hex: "0d0887")
        ]
    }
}
