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
    
    @available(macOS 10.15, *)
    @Test func createLunationPeriod() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate: Date? = formatter.date(from: "2020-01-06 18:14:00")
        let endDate: Date? = formatter.date(from: "2020-02-06 18:14:00")

        let lunation: SwiftMoon.LunationPeriod = SwiftMoon.LunationPeriod(
            lunationNumber: 1,
            lunationStartDate: startDate!,
            lunationEndDate: endDate!
        )

        #expect(lunation.lunationNumber == 1)
        #expect(lunation.lunationStartDate == startDate)
        #expect(lunation.lunationEndDate == endDate)
    }
    @available(macOS 10.15, *)
    @Test func lunationPeriodStartDate() async throws {
        let lunationStartDate: Date = SwiftMoon.LunationPeriod.getStartDate()
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expectedDate: Date? = formatter.date(from: "2000-01-06 18:14:00")

        #expect(lunationStartDate == expectedDate)
    }
    @available(macOS 10.15, *)
    @Test func getLunarPeriod() async throws {
        let lunarPeriod: Double = SwiftMoon.LunationPeriod.getLunarPeriod()
        let expectedPeriod: Double = 29.53059

        #expect(lunarPeriod == expectedPeriod)
    }
    @available(macOS 10.15, *)
    @Test func getLunationBackwardAndForwardIteration() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startingPeriod: Date? = formatter.date(from: "2000-01-06 18:14:00")

        let backwardIteration: Date = SwiftMoon.LunationPeriod.getIterationDate(
            startingPeriod: startingPeriod!, backwards: true
        )
        let futureIteration: Date = SwiftMoon.LunationPeriod.getIterationDate(
            startingPeriod: startingPeriod!
        )

        #expect(backwardIteration != futureIteration)
    }
    @available(macOS 10.15, *)
    @Test func getLunationPeriodsReturnsLunationPeriods() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date? = formatter.date(from: "2024-05-06 18:14:00")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon.LunationPeriod.getLunationPeriods(
            currentDate: date!)

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods.last!

        #expect(lunationPeriods.count > 1)
        #expect(lunationPeriod.lunationStartDate <= date!)
        #expect(lunationPeriod.lunationEndDate > date!)
    }
}
