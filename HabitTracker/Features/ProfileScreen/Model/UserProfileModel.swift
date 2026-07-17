//
//  UserProfileModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import Foundation

struct UserProfileModel {
    let id: UUID?
    let name: String
    let avatarData: Data?
    let theme: AppTheme
}
