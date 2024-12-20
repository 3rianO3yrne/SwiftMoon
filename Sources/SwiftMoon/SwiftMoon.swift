// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@available(macOS 13, *)
public enum SwiftMoon {
    
    
    /// Get the Meeus inspired "close enough" LunationPeriod
    /// - Parameter date: date to search
    /// - Returns:LunationPeriod
    public static func getMoonForDate(date: Date) -> LunationPeriod {
        return LunationPeriod.getLunationPeriods(currentDate: date).last!
    }
}
