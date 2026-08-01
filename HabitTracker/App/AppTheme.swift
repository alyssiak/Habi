//
//  AppTheme.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

import UIKit

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func apply() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { window in
                window.overrideUserInterfaceStyle = userInterfaceStyle
                window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
    }
}
