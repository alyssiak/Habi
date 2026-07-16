//
//  ProfileViewModel.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import Foundation
import Combine

final class ProfileViewModel {
    //MARK: - Properties
    @Published private(set) var state = ProfileViewState(
        avatarData: nil,
        userName: "Alice",
        quoteText: "Track your habits to stay motivated.",
        quoteAuthor: nil,
        bubbleMetrics: [],
        settingsItems: []
    )

    private let repository: HabitRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let statsCalculator: HabitStatsCalculating
    private let quoteService: QuoteServiceProtocol
    private var quote: Quote?
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Initialization
    init(
        repository: HabitRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        statsCalculator: HabitStatsCalculating,
        quoteService: QuoteServiceProtocol
    ) {
        self.repository = repository
        self.profileRepository = profileRepository
        self.statsCalculator = statsCalculator
        self.quoteService = quoteService
        bindRepositoryChanges()
    }

    //MARK: - Public methods
    func loadProfile() {
        state = makeState()
    }

    func loadQuote() async {
        do {
            let quote = try await quoteService.fetchQuote()

            await MainActor.run {
                self.quote = quote
                self.state = self.makeState()
            }
        } catch {
            print(error)
        }
    }

    func updateUserName(_ userName: String) {
        profileRepository.updateName(userName)
    }

    //MARK: - Binding
    private func bindRepositoryChanges() {
        repository.changesPublisher
            .sink { [weak self] _ in
                self?.loadProfile()
            }
            .store(in: &cancellables)

        profileRepository.changesPublisher
            .sink { [weak self] _ in
                self?.loadProfile()
            }
            .store(in: &cancellables)
    }

    private func makeState() -> ProfileViewState {
        let profile = profileRepository.fetchProfile()
        let habits = repository.fetchHabits()
        let weeklyProgress = makeWeeklyProgress(from: habits)
        let overallStats = makeOverallStats(from: habits)
        let perfectDays = makePerfectDaysCount(from: habits)

        return ProfileViewState(
            avatarData: profile.avatarData,
            userName: profile.name,
            quoteText: quote?.text ?? "Track your habits to stay motivated.",
            quoteAuthor: quote?.author,
            bubbleMetrics: [
                ProfileBubbleMetric(
                    value: "\(overallStats.currentStreak)",
                    title: "Current\nstreak",
                    style: .pink
                ),
                ProfileBubbleMetric(
                    value: "\(overallStats.bestStreak)",
                    title: "Best\nstreak",
                    style: .blue
                ),
                ProfileBubbleMetric(
                    value: makePercentText(weeklyProgress),
                    title: "Completion\nrate",
                    style: .purple
                ),
                ProfileBubbleMetric(
                    value: "\(perfectDays)",
                    title: "Perfect\ndays",
                    style: .orange
                )
            ],
            settingsItems: [
                ProfileSettingsItem(
                    title: "Theme",
                    subtitle: "System",
                    iconName: "moon",
                    accessory: .chevron
                ),
                ProfileSettingsItem(
                    title: "Language",
                    subtitle: "English",
                    iconName: "globe",
                    accessory: .chevron
                ),
                ProfileSettingsItem(
                    title: "Daily reminder",
                    subtitle: "Coming soon",
                    iconName: "bell",
                    accessory: .switcher(isOn: false)
                ),
                ProfileSettingsItem(
                    title: "About",
                    subtitle: "HabitTracker MVP",
                    iconName: "info.circle",
                    accessory: .chevron
                )
            ]
        )
    }
}

//MARK: - Profile Metrics
private extension ProfileViewModel {
    func makeOverallStats(from habits: [Habit]) -> HabitStats {
        let records = habits.flatMap { habit in
            repository.fetchRecords(for: habit)
        }

        return statsCalculator.makeStats(from: records)
    }

    func makeWeeklyProgress(from habits: [Habit]) -> Double {
        let weekDates = makeCurrentWeekDatesUntilToday()

        guard !habits.isEmpty, !weekDates.isEmpty else {
            return 0
        }

        let completedCount = habits.reduce(0) { result, habit in
            result + weekDates.filter { date in
                repository.isHabitCompleted(habit, on: date)
            }.count
        }

        let totalCount = habits.count * weekDates.count
        return Double(completedCount) / Double(totalCount)
    }

    func makePerfectDaysCount(from habits: [Habit]) -> Int {
        let weekDates = makeCurrentWeekDatesUntilToday()

        guard !habits.isEmpty else {
            return 0
        }

        return weekDates.filter { date in
            habits.allSatisfy { habit in
                repository.isHabitCompleted(habit, on: date)
            }
        }.count
    }

    func makeCurrentWeekDatesUntilToday() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return [today]
        }

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
        }
        .filter { date in
            calendar.startOfDay(for: date) <= today
        }
    }

    func makePercentText(_ progress: Double) -> String {
        "\(Int((progress * 100).rounded()))%"
    }

}
