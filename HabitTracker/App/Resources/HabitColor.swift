//
//  Color.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 07.05.2026.
//

import UIKit

enum ColorPalettes {
    struct HabitColor {
        let name: String
        let hex: String

        var uiColor: UIColor {
            UIColor(hex: hex)
        }
    }

    static let habitPalette: [HabitColor] = [
        HabitColor(name: "Sage Green", hex: "#7FB069"),
        HabitColor(name: "Lavender Purple", hex: "#9B7EDE"),
        HabitColor(name: "Sky Blue", hex: "#2770B5"),
        HabitColor(name: "Warm Orange", hex: "#F4A261"),
        HabitColor(name: "Soft Red", hex: "#E76F51"),
        HabitColor(name: "Stone Gray", hex: "#A8A29E"),
    ]
}
