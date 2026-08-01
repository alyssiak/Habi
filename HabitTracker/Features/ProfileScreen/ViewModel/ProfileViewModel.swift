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
        theme: .system,
        language: .english,
        quoteTitle: "Quote of the day",
        quoteText: "Track your habits to stay motivated.",
        quoteAuthor: nil,
        weeklySnapshotTitle: "Weekly snapshot",
        settingsTitle: "Settings",
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

    func updateTheme(_ theme: AppTheme) {
        profileRepository.updateTheme(theme)
    }

    func updateLanguage(_ language: AppLanguage) {
        profileRepository.updateLanguage(language)
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
            theme: profile.theme,
            language: profile.language,
            quoteTitle: AppStrings.quoteTitle(profile.language),
            quoteText: makeQuoteText(language: profile.language),
            quoteAuthor: makeQuoteAuthor(language: profile.language),
            weeklySnapshotTitle: AppStrings.weeklySnapshot(profile.language),
            settingsTitle: AppStrings.settings(profile.language),
            bubbleMetrics: [
                ProfileBubbleMetric(
                    value: "\(overallStats.currentStreak)",
                    title: AppStrings.currentStreak(profile.language),
                    style: .pink
                ),
                ProfileBubbleMetric(
                    value: "\(overallStats.bestStreak)",
                    title: AppStrings.bestStreak(profile.language),
                    style: .blue
                ),
                ProfileBubbleMetric(
                    value: makePercentText(weeklyProgress),
                    title: AppStrings.completionRate(profile.language),
                    style: .purple
                ),
                ProfileBubbleMetric(
                    value: "\(perfectDays)",
                    title: AppStrings.perfectDays(profile.language),
                    style: .orange
                )
            ],
            settingsItems: [
                ProfileSettingsItem(
                    title: AppStrings.theme(profile.language),
                    subtitle: AppStrings.themeTitle(profile.theme, language: profile.language),
                    iconName: "moon",
                    accessory: .chevron,
                    action: .theme
                ),
                ProfileSettingsItem(
                    title: AppStrings.language(profile.language),
                    subtitle: profile.language.title,
                    iconName: "globe",
                    accessory: .chevron,
                    action: .language
                ),
                ProfileSettingsItem(
                    title: AppStrings.dailyReminder(profile.language),
                    subtitle: AppStrings.comingSoon(profile.language),
                    iconName: "bell",
                    accessory: .switcher(isOn: false),
                    action: .reminders
                ),
                ProfileSettingsItem(
                    title: AppStrings.about(profile.language),
                    subtitle: AppStrings.appVersion(profile.language),
                    iconName: "info.circle",
                    accessory: .chevron,
                    action: .about
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

    func makeQuoteText(language: AppLanguage) -> String {
        guard language == .english else {
            return AppStrings.fallbackQuote(language)
        }

        return quote?.text ?? AppStrings.fallbackQuote(language)
    }

    func makeQuoteAuthor(language: AppLanguage) -> String? {
        guard language == .english else {
            return nil
        }

        return quote?.author
    }
}
