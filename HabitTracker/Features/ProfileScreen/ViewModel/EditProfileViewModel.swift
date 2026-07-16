//
//  EditProfileViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 16.07.2026.
//

import Foundation
import Combine

final class EditProfileViewModel {
    @Published private(set) var state = EditProfileViewState(
        name: "",
        avatarData: nil
    )
    
    private let profileRepository: ProfileRepositoryProtocol
    private var selectedAvatarData: Data?
    
    init(profileRepository: ProfileRepositoryProtocol) {
        self.profileRepository = profileRepository
    }
    
    func loadProfile() {
        let profile = profileRepository.fetchProfile()
        selectedAvatarData = profile.avatarData
        
        state = EditProfileViewState(
            name: profile.name,
            avatarData: selectedAvatarData
        )
    }
    
    func updateSelectedAvatarData(_ data: Data?) {
        selectedAvatarData = data
        
        state = EditProfileViewState(
            name: state.name,
            avatarData: data
        )
    }
    
    func save(name: String) {
        profileRepository.updateName(name)
        profileRepository.updateAvatarData(selectedAvatarData)
    }
}
