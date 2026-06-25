//
//  HabitStatsCalculatorTests.swift
//  HabitStatsCalculatorTests
//
//  Created by Alice Kamyshenko on 25.06.2026.
//

import XCTest
@testable import HabitTracker

final class HabitStatsCalculatorTests: XCTestCase {
    private var calculator: HabitStatsCalculator!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        calculator = HabitStatsCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - Empty State
    func testMakeStatsReturnsZeroValuesWhenDatesAreEmpty() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        let stats = calculator.makeStats(
            fromCompletedDates: [],
            today: today
        )
        
        XCTAssertEqual(stats.currentStreak, 0)
        XCTAssertEqual(stats.bestStreak, 0)
        XCTAssertEqual(stats.completedDays, 0)
    }
    
    // MARK: - Completed Days
    func testMakeStatsCountsUniqueCompletedDays() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        let sameDayMorning = makeDate(year: 2026, month: 6, day: 24, hour: 9)
        let sameDayEvening = makeDate(year: 2026, month: 6, day: 24, hour: 20)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [sameDayMorning, sameDayEvening, today],
            today: today
        )
        
        XCTAssertEqual(stats.completedDays, 2)
    }
    
    // MARK: - Current Streak
    func testMakeStatsCalculatesCurrentStreakIncludingToday() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        let yesterday = makeDate(year: 2026, month: 6, day: 24)
        let twoDaysAgo = makeDate(year: 2026, month: 6, day: 23)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [yesterday, twoDaysAgo, today],
            today: today
        )
        
        XCTAssertEqual(stats.currentStreak, 3)
    }
    
    func testMakeStatsCalculatesCurrentStreakFromYesterdayWhenTodayIsNotCompleted() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        let yesterday = makeDate(year: 2026, month: 6, day: 24)
        let twoDaysAgo = makeDate(year: 2026, month: 6, day: 23)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [yesterday, twoDaysAgo],
            today: today
        )
        
        XCTAssertEqual(stats.currentStreak, 2)
    }
    
    func testMakeStatsStopsCurrentStreakWhenThereIsGap() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        let yesterday = makeDate(year: 2026, month: 6, day: 24)
        let threeDaysAgo = makeDate(year: 2026, month: 6, day: 22)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [yesterday, threeDaysAgo, today],
            today: today
        )
        
        XCTAssertEqual(stats.currentStreak, 2)
    }
    
    // MARK: - Best Streak
    func testMakeStatsCalculatesBestStreak() {
        let today = makeDate(year: 2026, month: 6, day: 25)

        let june1 = makeDate(year: 2026, month: 6, day: 1)
        let june2 = makeDate(year: 2026, month: 6, day: 2)
        let june3 = makeDate(year: 2026, month: 6, day: 3)
        
        let june10 = makeDate(year: 2026, month: 6, day: 10)
        let june11 = makeDate(year: 2026, month: 6, day: 11)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [
                june1,
                june2,
                june3,
                june10,
                june11
            ],
            today: today
        )
        
        XCTAssertEqual(stats.bestStreak, 3)
    }
    
    func testMakeStatsReturnsBestStreakOneForSingleCompletedDay() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [today],
            today: today
        )
        
        XCTAssertEqual(stats.bestStreak, 1)
    }
    
    //MARK: - Sorted dates
    func testMakeStatsHandlesUnsortedDates() {
        let today = makeDate(year: 2026, month: 6, day: 25)
        
        let june1 = makeDate(year: 2026, month: 6, day: 1)
        let june2 = makeDate(year: 2026, month: 6, day: 2)
        let june3 = makeDate(year: 2026, month: 6, day: 3)
        
        let stats = calculator.makeStats(
            fromCompletedDates: [
                june3,
                june1,
                june2
            ],
            today: today
        )
        
        XCTAssertEqual(stats.bestStreak, 3)
        XCTAssertEqual(stats.completedDays, 3)
    }
    
    // MARK: - Helpers
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components)!
    }
}
