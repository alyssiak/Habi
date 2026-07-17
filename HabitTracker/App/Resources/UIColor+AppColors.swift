//
//  UIColor+AppColors.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.06.2026.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1)
    }

    static let appGray = UIColor(hex: "#EBEBEB")
    static let appOrange = UIColor(hex: "#F59733")
    static let lastDaysGray = UIColor(hex: "#D9D9D9")
    static let nextDaysGray = UIColor(hex: "#DFDFDF")

    static let appBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(hex: "#181818")
            : .systemBackground
    }

    static let appSecondaryBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(hex: "#242424")
            : .secondarySystemBackground
    }
}
