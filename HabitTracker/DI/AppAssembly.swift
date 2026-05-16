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
        let repository = HabitRepository(context: coreDataService.context)
        let viewModel = HabitTrackerViewModel(repository: repository)
        let viewController = HabitTrackerViewController(viewModel: viewModel)
        
        return viewController
    }
}
