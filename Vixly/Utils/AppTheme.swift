import UIKit

enum AppTheme {
    static let primaryColor = UIColor(hex: "#D9F94A")
    static let secondaryColor = UIColor(hex: "#D0F0F9")
    static let blackColor = UIColor(hex: "#111111")
    
    static let backgroundColor = UIColor(hex: "#F5F7F6")
    static let cardBackgroundColor = UIColor.white
    static let navBarBackgroundColor = UIColor(hex: "#D0F0F9")
    
    static let textPrimary = UIColor(hex: "#111111")
    static let textSecondary = UIColor(hex: "#666666")
    static let textTertiary = UIColor(hex: "#999999")
    static let textQuaternary = UIColor(hex: "#BBBBBB")
    static let textAccent = UIColor(hex: "#4DD0E1")
    static let textDanger = UIColor(hex: "#E53935")

    // Auth screens use the exact colors from the supplied 375 x 812 designs.
    static let authHeaderColor = UIColor(hex: "#CFF3FA")
    static let authFieldBorderColor = UIColor(hex: "#DDE4E6")
    static let authButtonColor = UIColor(hex: "#E7FF63")
    static let onboardingButtonColor = UIColor(hex: "#D7FF00")
    static let onboardingDarkColor = UIColor(hex: "#141416")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
