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
            startingPeriod: startingPeriod!,
            direction: .backward
        )
        let futureIteration: Date = SwiftMoon.LunationPeriod.getIterationDate(
            startingPeriod: startingPeriod!,
            direction: .forward
        )

        #expect(backwardIteration != futureIteration)
    }
    @available(macOS 10.15, *)
    @Test func getLunationPeriodsReturnsLunationPeriods() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date? = formatter.date(from: "2024-05-06 18:14:00")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon
            .LunationPeriod.getLunationPeriods(
                currentDate: date!
            )

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods.last!

        #expect(lunationPeriods.count > 1)
        #expect(lunationPeriod.lunationStartDate <= date!)
        #expect(lunationPeriod.lunationEndDate > date!)
    }

    @available(macOS 10.15, *)
    @Test func lunationEndMustBeLargerThenSameDayCurrentDate() async throws {
        // note: previous version would have set this as a new moon
        // since it was checking the end of the day of the current date

        // currentDate:  2025-08-23 07:07:00 +0000
        // timeIntervalSinceReferenceDate: 777625620.0
        // lunationEndDate: 2025-08-23 20:57:44 +0000
        // timeIntervalSinceReferenceDate: 777675464.6600033

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = formatter.date(from: "2025-08-23 07:07:00")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon
            .LunationPeriod.getLunationPeriods(
                currentDate: currentDate!
            )

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods.last!

        #expect(lunationPeriod.lunationNumber == 316)
        #expect(lunationPeriod.lunationStartDate <= currentDate!)
        #expect(lunationPeriod.lunationEndDate > currentDate!)
    }

    @available(macOS 10.15, *)
    @Test func lunationStartIncludesNanoseconds() async throws {
        // note: previous version would have set this as a new moon
        // since it was checking the end of the day of the current date

        // almostExactEndDate:  2025-08-23 20:57:44 +0000
        // timeIntervalSinceReferenceDate: 777675464.0
        // largerByOneSecondEndDate:  2025-08-23 20:57:45 +0000
        // timeIntervalSinceReferenceDate: 777675465.0
        // lunationEndDate: 2025-08-23 20:57:44 +0000
        // timeIntervalSinceReferenceDate: 777675464.6600033

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let almostExactEndDate = formatter.date(from: "2025-08-23 20:57:44")
        let largerByOneSecondEndDate = formatter.date(
            from: "2025-08-23 20:57:45"
        )

        var lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon
            .LunationPeriod.getLunationPeriods(
                currentDate: almostExactEndDate!
            )

        let lunationPeriod1: SwiftMoon.LunationPeriod = lunationPeriods.last!

        #expect(lunationPeriod1.lunationNumber == 316)
        #expect(lunationPeriod1.lunationStartDate <= almostExactEndDate!)
        #expect(lunationPeriod1.lunationEndDate > almostExactEndDate!)

        lunationPeriods += SwiftMoon
            .LunationPeriod.getLunationPeriods(
                currentDate: largerByOneSecondEndDate!
            )

        let lunationPeriod2: SwiftMoon.LunationPeriod = lunationPeriods.last!

        #expect(
            lunationPeriod2.lunationStartDate == lunationPeriod1.lunationEndDate
        )

        #expect(lunationPeriod2.lunationNumber == 317)
        #expect(lunationPeriod2.lunationStartDate <= largerByOneSecondEndDate!)
        #expect(lunationPeriod2.lunationEndDate > largerByOneSecondEndDate!)
    }

}
