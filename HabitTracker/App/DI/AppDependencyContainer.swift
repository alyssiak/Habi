//
//  AppDependencyContainer.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import Foundation

final class AppDependencyContainer {
    let coreDataService: CoreDataService
    let repository: HabitRepositoryProtocol
    let profileRepository: ProfileRepositoryProtocol
    let quoteService: QuoteService
    let statsCalculator: HabitStatsCalculator
    let calendarBuilder: HabitCalendarBuilder

    init() {
        let coreDataService = CoreDataService()

        self.coreDataService = coreDataService
        self.repository = HabitRepository(context: coreDataService.context)
        self.profileRepository = CoreDataProfileRepository(context: coreDataService.context)
        self.quoteService = QuoteService()
        self.statsCalculator = HabitStatsCalculator()
        self.calendarBuilder = HabitCalendarBuilder()
    }
}
