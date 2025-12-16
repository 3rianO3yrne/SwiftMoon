//
//  SwiftMoon+LunationPeriod.swift
//  SwiftMoon
//
//  Created by Brian O’Byrne on 10/11/25.
//

import AstronomyEngine
import Foundation

extension SwiftMoon {

    public struct LunationPeriod: Equatable, Hashable {
        public let lunationNumber: Int
        public let lunationStartDate: Date
        public var lunationEndDate: Date

        init(
            lunationNumber: Int,
            lunationStartDate: Date,
            lunationEndDate: Date,
        ) {
            self.lunationNumber = lunationNumber
            self.lunationStartDate = lunationStartDate
            self.lunationEndDate = lunationEndDate
        }

        public static func getCurrentLunationPeriod(date: Date = Date())
            -> [LunationPeriod]
        {

            let result = Lunation.getLunations(for: date)
            return result
        }
    }

    enum LunationSearchDirection {
        case head
        case tail
    }

    struct Lunation {
        var lunations: [LunationPeriod]
        var currentLunation: LunationPeriod
        var currentDate: Date

        static func getStartDate() -> DateComponents {
            // first lunation start date (Lunation 0)
            // year: 2000, month: 1, day: 6, hour: 18, minute: 14, second: 24.574027061462402)
            // 2000-01-06 18:14:24 +0000

            return DateComponents(
                calendar: Calendar.current,
                timeZone: TimeZone(identifier: "GMT"),
                year: 2000,
                month: 1,
                day: 6,
                hour: 18,
                minute: 14,
                second: 24
            )

        }

        static func getComponents(for date: Date) -> DateComponents {

            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents(
                in: TimeZone(
                    identifier: "GMT"
                )!,
                from: date
            )

            return dateComponents

        }

        static func getDateFromAstroTime(time: astro_time_t) -> Date {
            let real_time = Astronomy_UtcFromTime(time)

            let cal = Calendar.current
            let components = DateComponents(
                calendar: cal,
                timeZone: TimeZone(identifier: "GMT"),
                year: Int(real_time.year),
                month: Int(real_time.month),
                day: Int(real_time.day),
                hour: Int(real_time.hour),
                minute: Int(real_time.minute),
                second: Int(real_time.second)
            )
            return cal.date(from: components)!

        }

        static func getDirection(currentDate: Date) -> LunationSearchDirection {

            if self.getStartDate().date! >= currentDate {
                return LunationSearchDirection.head
            }
            return LunationSearchDirection.tail
        }

        static func getEndDate(currentDate: Date) -> Date {
            let direction = self.getDirection(currentDate: currentDate)

            let endDate =
                switch direction {
                case .head:
                    self.getStartDate().date!
                case .tail:
                    currentDate
                @unknown default:
                    currentDate
                }

            return endDate
        }

        static func getStartDate(currentDate: Date) -> Date {
            let calendar = Calendar.current
            let direction = self.getDirection(currentDate: currentDate)

            let startDate =
                switch direction {
                case .head:
                    calendar
                        .date(
                            byAdding: DateComponents(month: -1, day: -1),
                            to: currentDate
                        )!
                case .tail:
                    self.getStartDate().date!
                @unknown default:
                    self.getStartDate().date!
                }

            return startDate

        }

        struct TempLunationPeriod: Equatable, Hashable {
            public let lunationNumber: Int?
            public let lunationStartDate: Date?
            public var lunationEndDate: Date?
        }

        public static func getLunations(for currentDate: Date)
            -> [LunationPeriod]
        {
            let calendar = Calendar.current

            let direction = self.getDirection(currentDate: currentDate)

            var lunations: [LunationPeriod] = []

            let startComponents = self.getComponents(
                for: self.getStartDate(currentDate: currentDate)
            )

            let endComponents = self.getComponents(
                for: self.getEndDate(currentDate: currentDate)
            )

            let astroStartTime = self.getAstroTime(
                for: startComponents.date!
            )
            let astroEndTime = self.getAstroTime(
                for: endComponents.date!
            )

            var current_mq = Astronomy_SearchMoonQuarter(astroStartTime)

            var time = current_mq.time
            var count = 0

            var temp: [TempLunationPeriod] = []

            var search = true
            while search {

                if current_mq.quarter == 0 {

                    let startDate = self.getDateFromAstroTime(time: time)

                    var tempLunation = TempLunationPeriod(
                        lunationNumber: count,
                        lunationStartDate: startDate,
                    )

                    // find the next new moon so we have the lunation end
                    // start end date search
                    var curNewMoon = current_mq
                    var currentNewMoonTime = curNewMoon.time
                    let endDate: Date =
                        calendar
                        .date(
                            byAdding: DateComponents(month: 1, day: 1),
                            to: startDate
                        )!
                    let curNewMoonAstroTime = self.getAstroTime(
                        for: endDate
                    )

                    while currentNewMoonTime.ut < curNewMoonAstroTime.ut {
                        curNewMoon = Astronomy_NextMoonQuarter(curNewMoon)
                        currentNewMoonTime = curNewMoon.time

                        if curNewMoon.quarter == 0 {

                            let endDate = self.getDateFromAstroTime(
                                time: currentNewMoonTime
                            )
                            tempLunation.lunationEndDate = endDate
                        }

                    }
                    // complete end date search

                    if direction == .tail {

                        let lunation = LunationPeriod(
                            lunationNumber: tempLunation.lunationNumber!,
                            lunationStartDate: tempLunation.lunationStartDate!,
                            lunationEndDate: tempLunation.lunationEndDate!
                        )

                        lunations.append(lunation)

                    } else {
                        temp.append(tempLunation)

                    }
                    count += 1
                }

                // find next moon and iterate
                current_mq = Astronomy_NextMoonQuarter(current_mq)
                time = current_mq.time

                // stop loop when time iteration puts us past the target end time
                if time.ut > astroEndTime.ut {
                    // convert to date and compare so we aren't splitting seconds
                    print("check guard rails")
                    print(time.ut)
                    print(astroEndTime.ut)
                    let curDate = getDateFromAstroTime(time: time)
                    let endDate = getDateFromAstroTime(time: astroEndTime)
                    print(curDate)
                    print(endDate)

                    if curDate > endDate {
                        print("stop search")

                        search = false
                    }

                }
            }

            // this is so the lunations before 0 have the correct number
            var negCount = -1
            if direction == .head {
                for x in temp.reversed() {
                    let lunation = LunationPeriod(
                        lunationNumber: negCount,
                        lunationStartDate: x.lunationStartDate!,
                        lunationEndDate: x.lunationEndDate!
                    )
                    negCount = negCount - 1

                    lunations.append(lunation)

                }
            }

            return lunations

        }

        static func getAstroTime(for date: Date) -> astro_time_t {
            let startComponents = self.getComponents(for: date)
            return Astronomy_MakeTime(
                Int32(startComponents.year!),
                Int32(startComponents.month!),
                Int32(startComponents.day!),
                Int32(startComponents.hour!),
                Int32(startComponents.minute!),
                Double(startComponents.second!)
            )
        }

    }
}
