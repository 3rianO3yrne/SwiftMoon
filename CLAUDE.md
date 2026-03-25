# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
swift build          # Build the package
swift test           # Run all tests
swift test --filter SwiftMoonTests/testMethodName  # Run a single test
```

## Architecture

SwiftMoon is a Swift Package Manager library for calculating lunar phases and lunation periods. It wraps a bundled C astronomy library for precision calculations.

### Modules

**SwiftMoon** (main target) — The public Swift API with two parallel implementations:

- **Modern API** (`SwiftMoon+LunationPeriod.swift`): Uses the bundled `AstronomyEngine` C library for high-precision calculations. This is the recommended path.
- **Legacy API** (`SwiftMoonLegacy+LunationPeriod.swift`): Deprecated. Uses a simple Meeus approximation (29.53059-day cycle), kept for backward compatibility.

**AstronomyEngine** (system library target) — Bundled C library (`Sources/AstronomyEngine/include/astronomy.c`, 13k+ lines) from [cosinekitty/astronomy](https://github.com/cosinekitty/astronomy). The Swift layer calls into it via the header at `Sources/AstronomyEngine/include/astronomy.h`.

### Core Data Model

```swift
struct LunationPeriod {
    let lunationNumber: Int     // Relative to reference point (0 = 2000-01-06 18:14:24 UTC)
    let lunationStartDate: Date // New Moon start
    let lunationEndDate: Date   // Next New Moon
}
```

### Public API

```swift
// Modern (recommended)
SwiftMoon.getLunationPeriod(date: Date = Date()) -> LunationPeriod

// Legacy (deprecated)
SwiftMoonLegacy.getMoonForDate(date: Date) -> LunationPeriod
SwiftMoonLegacy.getLunationPeriods(date: Date) -> [LunationPeriod]
```

### How the Modern Implementation Works

`Lunation` (internal helper in `SwiftMoon+LunationPeriod.swift`) uses `Astronomy_SearchMoonQuarter()` and `Astronomy_NextMoonQuarter()` from the C library to find exact New Moon moments. It searches bidirectionally from the reference date (lunation 0) to locate the lunation period containing the requested date.

The implementation handles floating-point precision quirks when converting between `AstroTime` and Swift `Date`.
