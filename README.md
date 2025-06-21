# SwiftMoon

SwiftMoon is a Swift package for calculating the current lunation period, which begins on the "New Moon".

## Features
- Calculate the current lunation period, lunation start date, and lunation end date
- Written in pure Swift

## Installation
Add SwiftMoon to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/yourusername/SwiftMoon.git", from: "1.0.0")
```

Then add "SwiftMoon" as a dependency for your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwiftMoon", package: "SwiftMoon")
    ]
)
```

## Usage
Import SwiftMoon in your Swift file:

```swift
import SwiftMoon

// Example: Get the current lunation period
let lunations = SwiftMoon.getMoonForDate(date: Date())
print(lunations)

// LunationPeriod(
//    lunationNumber: int, 
//    lunationStartDate: Date, 
//    lunationEndDate: Date,
// )
```

## Requirements
- Swift 5.3 or later
- macOS 10.15 or later

## Running Tests
To run the test suite:

```sh
swift test
```

## License
This project is licensed under the terms of the MIT license. See [LICENSE.md](LICENSE.md) for details.