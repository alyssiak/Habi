//
//  ProfileRepository.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import Foundation
import CoreData
import Combine

protocol ProfileRepositoryProtocol {
    var changesPublisher: AnyPublisher<Void, Never> { get }

    func fetchProfile() -> UserProfileModel
    func updateName(_ name: String)
    func updateAvatarData(_ data: Data?)
    func updateTheme(_ theme: AppTheme)
}

final class CoreDataProfileRepository: ProfileRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let changesSubject = PassthroughSubject<Void, Never>()

    var changesPublisher: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchProfile() -> UserProfileModel {
        let profile = fetchOrCreateProfile()
        let theme = AppTheme(rawValue: profile.themeRawValue ?? "") ?? .system

        return UserProfileModel(
            id: profile.id,
            name: profile.name ?? "Alice",
            avatarData: profile.avatarData,
            theme: theme
        )
    }

    func updateName(_ name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            return
        }

        let profile = fetchOrCreateProfile()
        profile.name = trimmedName
        profile.updatedAt = Date()
        save()
    }

    func updateAvatarData(_ data: Data?) {
        let profile = fetchOrCreateProfile()
        profile.avatarData = data
        profile.updatedAt = Date()
        save()
    }

    func updateTheme(_ theme: AppTheme) {
        let profile = fetchOrCreateProfile()
        profile.themeRawValue = theme.rawValue
        profile.updatedAt = Date()
        save()
    }
}

private extension CoreDataProfileRepository {
    func fetchOrCreateProfile() -> UserProfile {
        if let profile = fetchStoredProfile() {
            return profile
        }

        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Alice"
        profile.avatarData = nil
        profile.themeRawValue = AppTheme.system.rawValue
        profile.createdAt = Date()
        profile.updatedAt = Date()
        save()

        return profile
    }

    func fetchStoredProfile() -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print(error)
            return nil
        }
    }

    func save() {
        do {
            try context.save()
            changesSubject.send()
        } catch {
            print(error)
        }
    }
}
