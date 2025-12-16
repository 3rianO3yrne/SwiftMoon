// The Swift Programming Language
// https://docs.swift.org/swift-book

import AstronomyEngine
import Foundation

@available(macOS 10.15, *)
public enum SwiftMoon {

    /// Get the LunationPeriod
    /// - Parameter date: date to search
    /// - Returns:LunationPeriod
    public static func getLunationPeriod(date: Date = Date())
        -> LunationPeriod
    {
        return LunationPeriod.getCurrentLunationPeriod(date: date).last!
    }

}


@available(
    macOS,
    introduced: 10.15,
    deprecated,
    message: "Use SwiftMoon.getLunationPeriod() for improved accuracy"
)
public enum SwiftMoonLegacy {

    /// Get the Meeus inspired "close enough" LunationPeriod
    /// - Parameter date: date to search
    /// - Returns:LunationPeriod
    public static func getMoonForDate(date: Date) -> LunationPeriod {
        return LunationPeriod.getLunationPeriods(currentDate: date).last!
    }

    /// Get the Meeus inspired "close enough" LunationPeriods from the known starting lunation to a given date.
    /// - Parameter date: date to search
    /// - Returns: [LunationPeriod]
    public static func getLunationPeriods(date: Date) -> [LunationPeriod] {
        return LunationPeriod.getLunationPeriods(currentDate: date)
    }

}
