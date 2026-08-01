//
//  AppAssembly.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit

final class AppAssembly {
    private let container: AppDependencyContainer

    init(container: AppDependencyContainer = AppDependencyContainer()) {
        self.container = container
    }

    func buildHabitListScreen() -> UIViewController {
        
        let viewModel = HabitTrackerViewModel(
            repository: container.repository,
            statsCalculator: container.statsCalculator,
            calendarBuilder: container.calendarBuilder,
            profileRepository: container.profileRepository
        )
        
        let viewController = HabitTrackerViewController(
            viewModel: viewModel,
            makeDetailsViewController: { habitModel in
                let detailViewModel = HabitDetailsViewModel(
                    habitId: habitModel.id,
                    repository: self.container.repository,
                    statsCalculator: self.container.statsCalculator
                )
                
                return HabitDetailsViewController(
                    habit: habitModel,
                    viewModel: detailViewModel,
                    makeHabitFormViewController: { mode in
                        AddHabitViewController(
                            viewModel: viewModel,
                            mode: mode
                        )
                    }
                )
            },
            makeHabitFormViewController: { mode in
                AddHabitViewController(
                    viewModel: viewModel,
                    mode: mode
                )
            },
            makeArchiveViewController: {
                let archivedViewModel = ArchivedHabitsViewModel(repository: self.container.repository)
                return ArchivedHabitsViewController(
                    viewModel: archivedViewModel,
                    profileRepository: self.container.profileRepository
                )
            }
        )
        
        return viewController
    }
    
    func buildMainTabBar() -> UIViewController {
        let userProfile = container.profileRepository.fetchProfile()
        let habits = UINavigationController(rootViewController: buildHabitListScreen())
        habits.tabBarItem = UITabBarItem(
            title: AppStrings.habitsTab(userProfile.language),
            image: UIImage(systemName: "checklist"),
            tag: 0
        )
        
        let statisticsViewModel = StatisticsViewModel(
            repository: container.repository,
            statsCalculator: container.statsCalculator
        )
        
        let statistics = UINavigationController(
            rootViewController: StatisticsViewController(
                viewModel: statisticsViewModel,
                profileRepository: container.profileRepository
            )
        )
        statistics.tabBarItem = UITabBarItem(
            title: AppStrings.statisticsTab(userProfile.language),
            image: UIImage(systemName: "chart.bar"),
            tag: 1
        )
        
        let profileViewModel = ProfileViewModel(
            repository: container.repository,
            profileRepository: container.profileRepository,
            statsCalculator: container.statsCalculator,
            quoteService: container.quoteService
        )
        let profile = UINavigationController(rootViewController: ProfileViewController(
            viewModel: profileViewModel,
            makeEditProfileViewController: {
                let editProfileViewModel = EditProfileViewModel(
                    profileRepository: self.container.profileRepository
                )
                return EditProfileViewController(viewModel: editProfileViewModel)
            }
        ))
        profile.tabBarItem = UITabBarItem(
            title: AppStrings.profileTab(userProfile.language),
            image: UIImage(systemName: "person"),
            tag: 2
        )

        let mainTabBarController = MainTabBarController(viewControllers: [habits, statistics, profile])
        mainTabBarController.overrideUserInterfaceStyle = userProfile.theme.userInterfaceStyle

        return mainTabBarController
    }
}
