//
//  DesignSystem.swift
//  notetakingmvcuikit
//
//  🎨 DESIGN SYSTEM - Beautiful MVC Notes App
//
//  This file contains all the design constants, colors, fonts, and styling
//  utilities to create a beautiful, modern interface that enhances the
//  MVC learning experience.
//

import UIKit

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // iOS Blue
        static let primaryLight = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        static let primaryDark = UIColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)
        
        // Gradient Colors
        static let gradientStart = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        static let gradientEnd = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        
        // Background Colors
        static let backgroundPrimary = UIColor.systemBackground
        static let backgroundSecondary = UIColor.secondarySystemBackground
        static let backgroundCard = UIColor.systemBackground
        
        // Text Colors
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel
        
        // Accent Colors
        static let success = UIColor.systemGreen
        static let warning = UIColor.systemOrange
        static let error = UIColor.systemRed
        
        // Shadow Colors
        static let shadow = UIColor.black.withAlphaComponent(0.1)
        static let shadowStrong = UIColor.black.withAlphaComponent(0.2)
    }
    
    // MARK: - Typography
    struct Typography {
        // App Title
        static let appTitle = UIFont.boldSystemFont(ofSize: 32)
        static let appSubtitle = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        // Navigation
        static let navigationTitle = UIFont.boldSystemFont(ofSize: 18)
        
        // Content
        static let headline = UIFont.boldSystemFont(ofSize: 22)
        static let title = UIFont.boldSystemFont(ofSize: 18)
        static let body = UIFont.systemFont(ofSize: 16)
        static let caption = UIFont.systemFont(ofSize: 14)
        static let footnote = UIFont.systemFont(ofSize: 12)
        
        // Notes
        static let noteTitle = UIFont.boldSystemFont(ofSize: 17)
        static let noteContent = UIFont.systemFont(ofSize: 15)
        static let noteDate = UIFont.systemFont(ofSize: 13)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
        static let xxlarge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let light = ShadowStyle(
            color: Colors.shadow,
            offset: CGSize(width: 0, height: 2),
            radius: 4,
            opacity: 0.1
        )
        
        static let medium = ShadowStyle(
            color: Colors.shadow,
            offset: CGSize(width: 0, height: 4),
            radius: 8,
            opacity: 0.15
        )
        
        static let strong = ShadowStyle(
            color: Colors.shadowStrong,
            offset: CGSize(width: 0, height: 8),
            radius: 16,
            opacity: 0.2
        )
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick: TimeInterval = 0.2
        static let medium: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.3
    }
}

// MARK: - Shadow Style
struct ShadowStyle {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

// MARK: - UI Extensions for Beautiful Design
extension UIView {
    
    // MARK: - Gradient Background
    func addGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0), endPoint: CGPoint = CGPoint(x: 1, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        
        // Remove existing gradient layers
        layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - Card Style
    func applyCardStyle(shadow: ShadowStyle = DesignSystem.Shadow.medium) {
        backgroundColor = DesignSystem.Colors.backgroundCard
        layer.cornerRadius = DesignSystem.CornerRadius.medium
        layer.shadowColor = shadow.color.cgColor
        layer.shadowOffset = shadow.offset
        layer.shadowRadius = shadow.radius
        layer.shadowOpacity = shadow.opacity
        layer.masksToBounds = false
    }
    
    // MARK: - Rounded Corners
    func roundCorners(radius: CGFloat = DesignSystem.CornerRadius.medium) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    // MARK: - Border
    func addBorder(color: UIColor = DesignSystem.Colors.primary, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    // MARK: - Pulse Animation
    func addPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(pulse, forKey: "pulse")
    }
    
    // MARK: - Bounce Animation
    func bounceIn() {
        transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        alpha = 0
        
        UIView.animate(
            withDuration: DesignSystem.Animation.medium,
            delay: 0,
            usingSpringWithDamping: DesignSystem.Animation.springDamping,
            initialSpringVelocity: DesignSystem.Animation.springVelocity,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }
    
    // MARK: - Slide In Animation
    func slideInFromBottom(delay: TimeInterval = 0) {
        transform = CGAffineTransform(translationX: 0, y: 50)
        alpha = 0
        
        UIView.animate(
            withDuration: DesignSystem.Animation.medium,
            delay: delay,
            options: .curveEaseOut
        ) {
            self.transform = .identity
            self.alpha = 1
        }
    }
}

// MARK: - Button Extensions
extension UIButton {
    
    // MARK: - Primary Button Style
    func applyPrimaryStyle() {
        backgroundColor = DesignSystem.Colors.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = DesignSystem.Typography.body
        roundCorners(radius: DesignSystem.CornerRadius.medium)
        
        // Add subtle shadow
        layer.shadowColor = DesignSystem.Colors.primary.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.3
        
        // Add press animation
        addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func buttonPressed() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.alpha = 0.8
        }
    }
    
    @objc private func buttonReleased() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}

// MARK: - Text Field Extensions
extension UITextField {
    
    // MARK: - Modern Text Field Style
    func applyModernStyle() {
        backgroundColor = DesignSystem.Colors.backgroundSecondary
        textColor = DesignSystem.Colors.textPrimary
        font = DesignSystem.Typography.body
        roundCorners()
        
        // Add padding
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSystem.Spacing.medium, height: frame.height))
        leftViewMode = .always
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: DesignSystem.Spacing.medium, height: frame.height))
        rightViewMode = .always
    }
}

// MARK: - Text View Extensions
extension UITextView {
    
    // MARK: - Modern Text View Style
    func applyModernStyle() {
        backgroundColor = DesignSystem.Colors.backgroundSecondary
        textColor = DesignSystem.Colors.textPrimary
        font = DesignSystem.Typography.body
        roundCorners()
        textContainerInset = UIEdgeInsets(
            top: DesignSystem.Spacing.medium,
            left: DesignSystem.Spacing.medium,
            bottom: DesignSystem.Spacing.medium,
            right: DesignSystem.Spacing.medium
        )
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    
    // MARK: - Hex Color Support
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    // MARK: - Color Utilities
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}