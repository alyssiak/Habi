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
            quoteService: container.quoteService,
            statsCalculator: container.statsCalculator,
            calendarBuilder: container.calendarBuilder
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
                return ArchivedHabitsViewController(viewModel: archivedViewModel)
            }
        )
        
        return viewController
    }
    
    func buildMainTabBar() -> UIViewController {
        let habits = UINavigationController(rootViewController: buildHabitListScreen())
        habits.tabBarItem = UITabBarItem(title: "Habits", image: UIImage(systemName: "checklist"), tag: 0)
        
        let statisticsViewModel = StatisticsViewModel(
            repository: container.repository,
            statsCalculator: container.statsCalculator
        )
        
        let statistics = UINavigationController(rootViewController: StatisticsViewController(viewModel: statisticsViewModel))
        statistics.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(systemName: "chart.bar"), tag: 1)
        
        let profileViewModel = ProfileViewModel(
            repository: container.repository,
            profileRepository: container.profileRepository,
            statsCalculator: container.statsCalculator
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
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2)

        return MainTabBarController(viewControllers: [habits, statistics, profile])
    }
}
