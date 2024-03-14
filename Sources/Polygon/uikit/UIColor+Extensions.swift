//
//  UIColor+Extensions.swift
//
//
//  Created by eclypse on 3/14/24.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init(hex: String) {
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
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Viridis palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var viridisPalette: [UIColor] {
        return [UIColor(hex: "fde725"),
            UIColor(hex: "a0da39"),
            UIColor(hex: "4ac16d"),
            UIColor(hex: "1fa187"),
            UIColor(hex: "277f8e"),
            UIColor(hex: "365c8d"),
            UIColor(hex: "46327e"),
            UIColor(hex: "440154")
        ]
    }
    
    /// Magma palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var magmaPalette: [UIColor] {
        return [UIColor(hex: "fcfdbf"),
            UIColor(hex: "febb81"),
            UIColor(hex: "f8765c"),
            UIColor(hex: "d3436e"),
            UIColor(hex: "982d80"),
            UIColor(hex: "5f187f"),
            UIColor(hex: "221150"),
            UIColor(hex: "000004")
        ]
    }
    
    
    /// Inferno palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var infernoPalette: [UIColor] {
        return [UIColor(hex: "fcffa4"),
            UIColor(hex: "fac228"),
            UIColor(hex: "f57d15"),
            UIColor(hex: "d44842"),
            UIColor(hex: "9f2a63"),
            UIColor(hex: "65156e"),
            UIColor(hex: "280b53"),
            UIColor(hex: "000004")
        ]
    }
    
    /// Plasma palette is colorblind-friendly, retain representational clarity in greyscale, and are generally aesthetically pleasing.
    ///
    /// The matplotlib colormaps introduced in 2015 are widely popular, with implementations of
    /// the palettes in R, D3js, and others.
    ///
    /// - SeeAlso: [Matplotlib](https://bids.github.io/colormap/)
    static var plasmaPalette: [UIColor] {
        return [UIColor(hex: "f0f921"),
            UIColor(hex: "febd2a"),
            UIColor(hex: "f48849"),
            UIColor(hex: "db5c68"),
            UIColor(hex: "b83289"),
            UIColor(hex: "8b0aa5"),
            UIColor(hex: "5302a3"),
            UIColor(hex: "0d0887")
        ]
    }
    
    /// rainbow colors for testing purposes
    static var rainbowPalette: [UIColor] {
        return [UIColor(hex: "FF0000"),
            UIColor(hex: "FF8000"),
            UIColor(hex: "FFFF00"),
            UIColor(hex: "00FF00"),
            UIColor(hex: "00FFFF"),
            UIColor(hex: "0000FF"),
            UIColor(hex: "8000FF")
        ]
    }
}

#endif
