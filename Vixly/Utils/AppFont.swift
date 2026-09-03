import UIKit

enum AppFont {
    static func authTitle() -> UIFont {
        UIFont(name: "Impact", size: 50) ?? .systemFont(ofSize: 50, weight: .black)
    }

    static func authLabel() -> UIFont {
        .systemFont(ofSize: 11, weight: .semibold)
    }

    static func authField() -> UIFont {
        .systemFont(ofSize: 14, weight: .regular)
    }

    static func authButton() -> UIFont {
        .systemFont(ofSize: 11, weight: .bold)
    }

    static func h1(_ weight: UIFont.Weight = .black) -> UIFont {
        return .systemFont(ofSize: 40, weight: weight)
    }
    
    static func h4(_ weight: UIFont.Weight = .black) -> UIFont {
        return .systemFont(ofSize: 34, weight: weight)
    }
    
    static func h2(_ weight: UIFont.Weight = .bold) -> UIFont {
        return .systemFont(ofSize: 28, weight: weight)
    }
    
    static func h5(_ weight: UIFont.Weight = .bold) -> UIFont {
        return .systemFont(ofSize: 24, weight: weight)
    }
    
    static func h3(_ weight: UIFont.Weight = .bold) -> UIFont {
        return .systemFont(ofSize: 20, weight: weight)
    }
    
    static func body(_ weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: 16, weight: weight)
    }
    
    static func subtitle(_ weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: 14, weight: weight)
    }
    
    static func caption(_ weight: UIFont.Weight = .regular) -> UIFont {
        return .systemFont(ofSize: 12, weight: weight)
    }
}
