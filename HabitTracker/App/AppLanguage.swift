//
//  AppLanguage.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

enum AppLanguage: String, CaseIterable {
    case english
    case russian

    var title: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        }
    }
}
