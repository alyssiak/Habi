//
//  HabitCalendarBuilderTests.swift
//  HabitStatsCalculatorTests
//
//  Created by Alice Kamyshenko on 10.07.2026.
//

import XCTest
@testable import HabitTracker

final class HabitCalendarBuilderTests: XCTestCase {
    private var builder: HabitCalendarBuilder!
    
    override func setUp() {
        super.setUp()
        builder = HabitCalendarBuilder()
    }
    
    override func tearDown() {
        builder = nil
        super.tearDown()
    }
    
    func testBuildDaysReturnsEmptyArrayWhenCreatedAtIsNil() {
        let today = makeDate(year: 2026, month: 7, day: 10)
        
        let days = builder.buildDays(
            createdAt: nil,
            completedDates: [],
            today: today
        )
        
        XCTAssertTrue(days.isEmpty)
    }

    func testBuildDaysMarksCompletedDay() {
        let createdAt = makeDate(year: 2026, month: 7, day: 1)
        let today = makeDate(year: 2026, month: 7, day: 10)
        let completedDate = makeDate(year: 2026, month: 7, day: 3, hour: 18)

        let days = builder.buildDays(
           createdAt: createdAt,
           completedDates: [completedDate],
           today: today
        )

        XCTAssertEqual(days[2].state, .completed)
    }
    
    func testBuildDaysMarksPastUncompletedDayAsMissed() {
           let createdAt = makeDate(year: 2026, month: 7, day: 1)
           let today = makeDate(year: 2026, month: 7, day: 10)

           let days = builder.buildDays(
               createdAt: createdAt,
               completedDates: [],
               today: today
           )

           XCTAssertEqual(days[0].state, .missed)
       }

       func testBuildDaysMarksFutureDayAsFuture() {
           let createdAt = makeDate(year: 2026, month: 7, day: 1)
           let today = makeDate(year: 2026, month: 7, day: 10)

           let days = builder.buildDays(
               createdAt: createdAt,
               completedDates: [],
               today: today
           )

           XCTAssertEqual(days[10].state, .future)
       }

       func testBuildDaysUsesCurrentThirtyDayBlock() {
           let createdAt = makeDate(year: 2026, month: 7, day: 1)
           let today = makeDate(year: 2026, month: 8, day: 5)

           let days = builder.buildDays(
               createdAt: createdAt,
               completedDates: [],
               today: today
           )

           XCTAssertEqual(days.first?.date, makeDate(year: 2026, month: 7, day: 31))
       }

       func testIsCompletedTodayReturnsTrueWhenCompletedDatesContainToday() {
           let today = makeDate(year: 2026, month: 7, day: 10)
           let todayEvening = makeDate(year: 2026, month: 7, day: 10, hour: 20)

           let isCompleted = builder.isCompletedToday(
               completedDates: [todayEvening],
               today: today
           )

           XCTAssertTrue(isCompleted)
       }

       private func makeDate(
           year: Int,
           month: Int,
           day: Int,
           hour: Int = 0
       ) -> Date {
           var components = DateComponents()
           components.year = year
           components.month = month
           components.day = day
           components.hour = hour

           return Calendar.current.date(from: components)!
       }
}
