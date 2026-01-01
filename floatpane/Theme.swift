import Foundation
import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    struct Palette: Codable, Equatable {
        let primary: String
        let secondary: String
        let background: String
        let surface: String
        let onPrimary: String
        let onSecondary: String
        let onBackground: String
        let onSurface: String
        let error: String
    }

    let name: String
    let colors: Palette

    var id: String { name }

    static let fallback = Theme(
        name: "Classic",
        colors: Palette(
            primary: "#5AC8FA",
            secondary: "#FFDD59",
            background: "#101014",
            surface: "#1C1C22",
            onPrimary: "#000000",
            onSecondary: "#000000",
            onBackground: "#FFFFFF",
            onSurface: "#FFFFFF",
            error: "#FF453A"
        )
    )
}

extension Theme {
    var primaryColor: Color { Color(hex: colors.primary) }
    var secondaryColor: Color { Color(hex: colors.secondary) }
    var backgroundColor: Color { Color(hex: colors.background) }
    var surfaceColor: Color { Color(hex: colors.surface) }
    var onPrimaryColor: Color { Color(hex: colors.onPrimary) }
    var onSecondaryColor: Color { Color(hex: colors.onSecondary) }
    var onBackgroundColor: Color { Color(hex: colors.onBackground) }
    var onSurfaceColor: Color { Color(hex: colors.onSurface) }
    var errorColor: Color { Color(hex: colors.error) }
}

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch sanitized.count {
        case 8:
            a = (int & 0xFF000000) >> 24
            r = (int & 0x00FF0000) >> 16
            g = (int & 0x0000FF00) >> 8
            b = int & 0x000000FF
        case 6:
            a = 255
            r = (int & 0x00FF0000) >> 16
            g = (int & 0x0000FF00) >> 8
            b = int & 0x000000FF
        default:
            a = 255
            r = 255
            g = 255
            b = 255
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
