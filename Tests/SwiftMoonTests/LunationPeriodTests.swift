//
//  LunationPeriodTests.swift
//  PenobscotNamesOfTheMoons
//
//  Created by Brian O’Byrne on 11/29/24.
//

import Foundation
import Testing

@testable import SwiftMoon

struct LunationPeriodTests {

    @Test func createLunationPeriod() async throws {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate = formatter.date(from: "2020-01-06 18:14:00")
        let endDate = formatter.date(from: "2020-02-06 18:14:00")

        let lunation = LunationPeriod(
            lunationNumber: 1,
            lunationStartDate: startDate!,
            lunationEndDate: endDate!
        )

        #expect(lunation.lunationNumber == 1)
        #expect(lunation.lunationStartDate == startDate)
        #expect(lunation.lunationEndDate == endDate)
    }

    @Test func lunationPeriodStartDate() async throws {
        let lunationStartDate = LunationPeriod.getStartDate()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expectedDate = formatter.date(from: "2000-01-06 18:14:00")

        #expect(lunationStartDate == expectedDate)
    }

    @Test func getLunarPeriod() async throws {
        let lunarPeriod = LunationPeriod.getLunarPeriod()
        let expectedPeriod: Double = 29.53059

        #expect(lunarPeriod == expectedPeriod)
    }

    @Test func getLunationBackwardAndForwardIteration() async throws {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startingPeriod = formatter.date(from: "2000-01-06 18:14:00")

        let backwardIteration = LunationPeriod.getIterationDate(
            startingPeriod: startingPeriod!, backwards: true
        )
        let futureIteration = LunationPeriod.getIterationDate(
            startingPeriod: startingPeriod!
        )

        #expect(backwardIteration != futureIteration)
    }

    @Test func getLunationPeriodsReturnsLunationPeriods() async throws {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: "2024-05-06 18:14:00")

        let lunationPeriods = LunationPeriod.getLunationPeriods(
            currentDate: date!)

        let lunationPeriod = lunationPeriods.last!

        #expect(lunationPeriods.count > 1)
        #expect(lunationPeriod.lunationStartDate <= date!)
        #expect(lunationPeriod.lunationEndDate > date!)
    }
}
