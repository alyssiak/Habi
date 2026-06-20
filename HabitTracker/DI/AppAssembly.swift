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
        let repository = HabitRepository(context: coreDataService.context)
        let viewModel = HabitTrackerViewModel(repository: repository, quoteService: quoteService)
        let viewController = HabitTrackerViewController(
            viewModel: viewModel,
            makeDetailsViewController: { habitModel in
                let detailViewModel = HabitDetailsViewModel(
                    habitId: habitModel.id,
                    repository: repository
                )
                
                return HabitDetailsViewController(
                    habit: habitModel,
                    viewModel: detailViewModel
                )
            }
        )
        
        return viewController
    }
}
