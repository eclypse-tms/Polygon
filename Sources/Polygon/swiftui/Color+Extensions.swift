//
//  Color+Hex.swift
//
//
//  Created by eclypse on 3/8/24.
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
    
    
    /// Viridis palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var viridisPalette: [Color] {
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
    
    /// Magma palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var magmaPalette: [Color] {
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
    
    
    /// Inferno palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var infernoPalette: [Color] {
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
    
    /// Plasma palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var plasmaPalette: [Color] {
        return [Color(hex: "f0f921"),
            Color(hex: "febd2a"),
            Color(hex: "f48849"),
            Color(hex: "db5c68"),
            Color(hex: "b83289"),
            Color(hex: "8b0aa5"),
            Color(hex: "5302a3"),
            Color(hex: "0d0887")
        ]
    }
    
    /// rainbow colors for testing purposes
    static var rainbowPalette: [Color] {
        return [Color(hex: "FF0000"),
            Color(hex: "FF8000"),
            Color(hex: "FFFF00"),
            Color(hex: "00FF00"),
            Color(hex: "00FFFF"),
            Color(hex: "0000FF"),
            Color(hex: "8000FF")
        ]
    }
}

public extension Color {
    #if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
    #else
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    #endif
}
