//
//  Color.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 07.05.2026.
//

import Foundation
import UIKit

final class ColorPalette {
    struct HabitColor {
        let hex: String
        let uiColor: UIColor
    }

    static let palette: [HabitColor] = [
        HabitColor(hex: "#FF6347", uiColor: .systemRed),
        HabitColor(hex: "#FFFDE7", uiColor: .systemYellow),
        HabitColor(hex: "#E7FFC5", uiColor: .systemGreen),
        HabitColor(hex: "#B2F5A9", uiColor: .systemBlue),
    ]
}

