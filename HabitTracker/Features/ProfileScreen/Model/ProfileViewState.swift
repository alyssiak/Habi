//
//  ProfileViewState.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import Foundation

struct ProfileViewState {
    let avatarData: Data?
    let userName: String
    let quoteText: String
    let quoteAuthor: String?
    let bubbleMetrics: [ProfileBubbleMetric]
    let settingsItems: [ProfileSettingsItem]
}

struct ProfileSettingsItem {
    let title: String
    let subtitle: String?
    let iconName: String
    let accessory: ProfileSettingsAccessory
}

enum ProfileSettingsAccessory {
    case chevron
    case switcher(isOn: Bool)
}

struct ProfileBubbleMetric {
    let value: String
    let title: String
    let style: ProfileBubbleMetricStyle
}

enum ProfileBubbleMetricStyle {
    case pink
    case blue
    case purple
    case orange
}
