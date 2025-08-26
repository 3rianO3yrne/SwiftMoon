//
//  SwiftMoon+LunationPeriod.swift
//  SwiftMoon
//
//  Created by Brian O’Byrne on 12/20/24.
//

import Foundation

@available(macOS 10.15, *)
extension SwiftMoon {

    public struct LunationPeriod: Equatable, Hashable {
        public let lunationNumber: Int
        public let lunationStartDate: Date
        public let lunationEndDate: Date

        static func getStartDate() -> Date {
            return DateComponents(
                calendar: Calendar(
                    identifier: .gregorian
                ),
                timeZone: TimeZone(identifier: "GMT"),
                year: 2000,
                month: 1,
                day: 6,
                hour: 18,
                minute: 14
            ).date!

        }

        public static func getLunarMonthPeriodDateComponents(
            direction: Calendar.SearchDirection = .forward
        )
            -> DateComponents
        {
            let directionMultiplier =
                switch direction {
                case .forward: 1
                case .backward: -1
                @unknown default: 1
                }

            let lunarCycleDays: Int = directionMultiplier * 29
            let lunarCycleSeconds: Int = directionMultiplier * 45842
            let lunarCycleNanoseconds: Int = directionMultiplier * 980_000_000

            return DateComponents(
                day: lunarCycleDays,
                second: lunarCycleSeconds,
                nanosecond: lunarCycleNanoseconds
            )
        }

        static func getLunarPeriod() -> Double {
            return 29.53059
        }

        static func getLunationInterval() -> TimeInterval {
            let knownNewMoon: Date = LunationPeriod.getStartDate()
            let lunarMonthComponent: DateComponents =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    direction: .backward
                )
            let lunationDate: Date? = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: knownNewMoon
            )

            let moonTime: TimeInterval = lunationDate!.timeIntervalSince(
                knownNewMoon
            )
            return moonTime
        }

        static func getIterationDate(
            startingPeriod: Date,
            direction: Calendar.SearchDirection = .forward
        )
            -> Date
        {

            let lunarMonthComponent: DateComponents =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    direction: direction
                )

            let lunationDate: Date? = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: startingPeriod
            )

            return lunationDate!
        }

        static func getLunationPeriods(currentDate: Date) -> [LunationPeriod] {

            let calendar: Calendar = Calendar.current
            let knownNewMoon: Date = LunationPeriod.getStartDate()

            let selectedDateComponents: DateComponents =
                calendar.dateComponents(
                    in: TimeZone(identifier: "GMT")!,
                    from: currentDate
                )

            let selectedDate: Date = selectedDateComponents.date!

            var newMoonDateIteration: Date = knownNewMoon
            var lunationCount: Int = 0

            var lunations: [LunationPeriod] = []

            let isdirectionBackwards: Bool =
                newMoonDateIteration > selectedDate

            let direction: Calendar.SearchDirection =
                isdirectionBackwards ? .backward : .forward

            let lunarMonthComponent: DateComponents =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    direction: direction
                )

            while isdirectionBackwards
                ? newMoonDateIteration > selectedDate
                : newMoonDateIteration < selectedDate
            {
                let moonStartDate: Date = Calendar(identifier: .gregorian)
                    .date(
                        byAdding: lunarMonthComponent,
                        to: newMoonDateIteration
                    )!

                let lunation: SwiftMoon.LunationPeriod =
                    LunationPeriod(
                        lunationNumber: lunationCount,
                        lunationStartDate: isdirectionBackwards
                            ? moonStartDate : newMoonDateIteration,
                        lunationEndDate: isdirectionBackwards
                            ? newMoonDateIteration : moonStartDate
                    )

                lunations.append(lunation)

                newMoonDateIteration = getIterationDate(
                    startingPeriod: newMoonDateIteration,
                    direction: isdirectionBackwards
                        ? .backward : .forward
                )

                lunationCount +=
                    isdirectionBackwards
                    ? -1 : 1
            }

            return lunations

        }
    }
}
