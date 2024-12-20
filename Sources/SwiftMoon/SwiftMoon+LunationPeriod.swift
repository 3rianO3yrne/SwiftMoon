//
//  SwiftMoon+LunationPeriod.swift
//  SwiftMoon
//
//  Created by Brian O’Byrne on 12/20/24.
//

import Foundation

@available(macOS 13, *)
extension SwiftMoon {

    public struct LunationPeriod: Equatable, Hashable {
        var lunationNumber: Int
        var lunationStartDate: Date
        var lunationEndDate: Date

        static func getStartDate() -> Date {
            return DateComponents(
                calendar: Calendar(
                    identifier: .gregorian
                ),
                timeZone: .gmt,
                year: 2000,
                month: 1,
                day: 6,
                hour: 18,
                minute: 14
            ).date!

        }

        static func getLunarMonthPeriodDateComponents(backwards: Bool = false)
            -> DateComponents
        {

            let lunarCycleDays = (backwards ? -1 : 1) * 29
            let lunarCycleSeconds = (backwards ? -1 : 1) * 45842
            let lunarCycleNanoseconds = (backwards ? -1 : 1) * 980_000_000

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
            let knownNewMoon = LunationPeriod.getStartDate()
            let lunarMonthComponent =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    backwards: false)
            let lunationDate = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: knownNewMoon)

            let moonTime = lunationDate!.timeIntervalSince(knownNewMoon)
            return moonTime
        }

        static func getIterationDate(
            startingPeriod: Date, backwards: Bool = false
        )
            -> Date
        {

            let lunarMonthComponent =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    backwards: backwards)

            let lunationDate = Calendar(identifier: .gregorian).date(
                byAdding: lunarMonthComponent,
                to: startingPeriod)

            return lunationDate!
        }

        static func getLunationPeriods(currentDate: Date) -> [LunationPeriod] {
            let calendar = Calendar.current
            let knownNewMoon = LunationPeriod.getStartDate()

            // get end of day date
            let nextDayDate = calendar.date(
                byAdding: .day, value: 1, to: currentDate)!
            let endOfDay = calendar.startOfDay(for: nextDayDate)

            let selectedDate = calendar.dateComponents(
                in: TimeZone.gmt,
                from: endOfDay
            )

            var newMoonDateIteration = knownNewMoon
            var lunationCount = 0

            var lunations: [LunationPeriod] = []

            let isBackwardDateIteration =
                newMoonDateIteration > selectedDate.date!

            let lunarMonthComponent =
                LunationPeriod.getLunarMonthPeriodDateComponents(
                    backwards: isBackwardDateIteration)

            if isBackwardDateIteration {
                var lunationCount = -1
                while newMoonDateIteration > selectedDate.date! {

                    let moonStartDate = Calendar(identifier: .gregorian).date(
                        byAdding: lunarMonthComponent,
                        to: newMoonDateIteration
                    )!

                    let lunation =
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

                    let moonEndDate = Calendar(identifier: .gregorian).date(
                        byAdding: lunarMonthComponent,
                        to: newMoonDateIteration
                    )!

                    let lunation = LunationPeriod(
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
