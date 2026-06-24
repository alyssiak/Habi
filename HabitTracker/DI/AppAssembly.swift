//
//  AppAssembly.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 30.04.2026.
//

import UIKit

final class AppAssembly {
    func buildHabitListScreen() -> UIViewController {
        let coreDataService = CoreDataService()
        let quoteService = QuoteService()
        let statsCalculator = HabitStatsCalculator()
        let repository = HabitRepository(context: coreDataService.context)
        
        let viewModel = HabitTrackerViewModel(
            repository: repository,
            quoteService: quoteService,
            statsCalculator: statsCalculator
        )
        
        let viewController = HabitTrackerViewController(
            viewModel: viewModel,
            makeDetailsViewController: { habitModel in
                let detailViewModel = HabitDetailsViewModel(
                    habitId: habitModel.id,
                    repository: repository,
                    statsCalculator: statsCalculator
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
                let archivedViewModel = ArchivedHabitsViewModel(repository: repository)
                return ArchivedHabitsViewController(viewModel: archivedViewModel)
            }
        )
        
        return viewController
    }
}
