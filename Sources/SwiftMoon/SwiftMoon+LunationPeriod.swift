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
            backwards: Bool = false
        )
            -> DateComponents
        {

            let lunarCycleDays: Int = (backwards ? -1 : 1) * 29
            let lunarCycleSeconds: Int = (backwards ? -1 : 1) * 45842
            let lunarCycleNanoseconds: Int = (backwards ? -1 : 1) * 980_000_000

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
                    backwards: false)
            let lunationDate: Date? = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: knownNewMoon)

            let moonTime: TimeInterval = lunationDate!.timeIntervalSince(knownNewMoon)
            return moonTime
        }

        static func getIterationDate(
            startingPeriod: Date, backwards: Bool = false
        )
            -> Date
        {

            let lunarMonthComponent: DateComponents =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    backwards: backwards)

            let lunationDate: Date? = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: startingPeriod)

            return lunationDate!
        }

        static func getLunationPeriods(currentDate: Date) -> [LunationPeriod] {
            let calendar: Calendar = Calendar.current
            let knownNewMoon: Date = LunationPeriod.getStartDate()

            // get end of day date
            let nextDayDate: Date = calendar.date(
                byAdding: .day, value: 1, to: currentDate)!
            let endOfDay: Date = calendar.startOfDay(for: nextDayDate)

            let selectedDate: DateComponents = calendar.dateComponents(
                in: TimeZone(identifier: "GMT")!,
                from: endOfDay
            )

            var newMoonDateIteration: Date = knownNewMoon
            var lunationCount: Int = 0

            var lunations: [LunationPeriod] = []

            let isBackwardDateIteration: Bool =
                newMoonDateIteration > selectedDate.date!

            let lunarMonthComponent: DateComponents =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    backwards: isBackwardDateIteration)

            if isBackwardDateIteration {
                var lunationCount: Int = -1
                while newMoonDateIteration > selectedDate.date! {

                    let moonStartDate: Date = Calendar(identifier: .gregorian).date(
                        byAdding: lunarMonthComponent,
                        to: newMoonDateIteration
                    )!

                    let lunation: SwiftMoon.LunationPeriod =
                        LunationPeriod(
                            lunationNumber: lunationCount,  // decreases after each loop
                            lunationStartDate: moonStartDate,
                            lunationEndDate: newMoonDateIteration)

                    lunations.append(lunation)

                    newMoonDateIteration = LunationPeriod.getIterationDate(
                        startingPeriod: newMoonDateIteration,
                        backwards: isBackwardDateIteration)

                    lunationCount = lunationCount - 1  // the operator depends on which direction we are looping to
                }

            } else {

                while newMoonDateIteration < selectedDate.date! {

                    let moonEndDate: Date = Calendar(identifier: .gregorian).date(
                        byAdding: lunarMonthComponent,
                        to: newMoonDateIteration
                    )!

                    let lunation: SwiftMoon.LunationPeriod = LunationPeriod(
                        lunationNumber: lunationCount,  // increases after each loop
                        lunationStartDate: newMoonDateIteration,
                        lunationEndDate: moonEndDate)

                    lunations.append(lunation)

                    newMoonDateIteration = LunationPeriod.getIterationDate(
                        startingPeriod: newMoonDateIteration,
                        backwards: isBackwardDateIteration)
                    lunationCount += 1  // the operator depends on which direction we are looping to

                }
            }

            return lunations

        }
    }
}
