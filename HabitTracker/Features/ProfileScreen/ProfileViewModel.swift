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
        userName: "Alice",
        subtitle: "Habit builder",
        profileMessage: "Small steps still count.",
        bubbleMetrics: [],
        settingsItems: []
    )

    private let repository: HabitRepositoryProtocol
    private let profileRepository: ProfileRepositoryProtocol
    private let statsCalculator: HabitStatsCalculating
    private var cancellables = Set<AnyCancellable>()

    //MARK: - Initialization
    init(
        repository: HabitRepositoryProtocol,
        profileRepository: ProfileRepositoryProtocol,
        statsCalculator: HabitStatsCalculating
    ) {
        self.repository = repository
        self.profileRepository = profileRepository
        self.statsCalculator = statsCalculator
        bindRepositoryChanges()
    }

    //MARK: - Public methods
    func loadProfile() {
        state = makeState()
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
            userName: profile.name,
            subtitle: "Habit builder",
            profileMessage: makeProfileMessage(progress: weeklyProgress),
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

    func makeProfileMessage(progress: Double) -> String {
        switch progress {
        case 0.8...:
            return "Amazing rhythm. Keep it steady."
        case 0.5..<0.8:
            return "You're building consistency. Keep going."
        case 0.1..<0.5:
            return "Small steps still count. Pick one habit today."
        default:
            return "Ready for a fresh start today."
        }
    }
}
