//
//  SwiftMoonTests.swift
//  PenobscotNamesOfTheMoons
//
//  Created by Brian O’Byrne on 11/29/24.
//

import Foundation
import Testing

@testable import SwiftMoon

struct SwiftMoonTests {

    @available(macOS 10.15, *)
    @Test func createLunationPeriod() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startDate: Date? = formatter.date(from: "2020-01-06 18:14:00")
        let endDate: Date? = formatter.date(from: "2020-02-06 18:14:00")

        let lunation: SwiftMoon.LunationPeriod =
            SwiftMoon.LunationPeriod(
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
        let lunationStartDate: Date = SwiftMoon.Lunation.getStartDate().date!
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expectedDate: Date? = formatter.date(from: "2000-01-06 18:14:24")

        #expect(lunationStartDate == expectedDate)
    }

    @available(macOS 10.15, *)
    @Test func getLunationPeriodsReturnsLunationPeriods() async throws {
        let formatter: DateFormatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date: Date? = formatter.date(from: "2024-05-06 18:14:00")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon.LunationPeriod.getCurrentLunationPeriod(date: date!)

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods
            .last!

        #expect(lunationPeriods.count == 301)
        // difference between count/lunationnumber due the first lunation is 0
        #expect(lunationPeriod.lunationNumber == 300)
        #expect(lunationPeriod.lunationStartDate <= date!)
        #expect(lunationPeriod.lunationEndDate > date!)
    }

    @available(macOS 10.15, *)
    @Test func lunationEndMustBeLargerThenSameDayCurrentDate() async throws {
        // note: previous version would have set this as a new moon
        // since it was checking the end of the day of the current date instead
        // of down to the second

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = formatter.date(from: "2025-08-23 06:07:06")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon.LunationPeriod.getCurrentLunationPeriod(date: currentDate!)

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods.last!
        
        #expect(lunationPeriod.lunationNumber == 316)
        #expect(lunationPeriod.lunationStartDate < currentDate!)
        #expect(lunationPeriod.lunationEndDate > currentDate!)
    }
    
    @available(macOS 10.15, *)
    @Test func usingAnExactStartDateGivesCorrectLunation() async throws {
        // addresses the fact the the astronomy lib useses floating point UTC calculations for the date math
        // for example using the date: 2025-08-23 06:07:07 +0000 -- which is a new moon
        // 9365.754948508531 -- this is the precises floating point new moon time
        // 9365.75494212963 -- this is not
        // but both values represent: 2025-08-23 06:07:07 +0000
        // TODO: should dry up the code so that it can be better represented when testing
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = formatter.date(from: "2025-08-23 06:07:07")

        let lunationPeriods: [SwiftMoon.LunationPeriod] = SwiftMoon.LunationPeriod.getCurrentLunationPeriod(date: currentDate!)

        let lunationPeriod: SwiftMoon.LunationPeriod = lunationPeriods.last!
        
        #expect(lunationPeriod.lunationNumber == 317)
        #expect(lunationPeriod.lunationStartDate == currentDate!)
        #expect(lunationPeriod.lunationEndDate > currentDate!)
    }

}
