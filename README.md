# RestaurantApp

An iOS app that lists restaurants and shows their details, built with UIKit and the **VIPER** architecture. Data comes from the [Dicoding Restaurant API](https://restaurant-api.dicoding.dev).

## Features

- Restaurant list with images and an empty state view
- Restaurant detail screen
- Remote image loading and caching
- Unit tests for the interactors, presenters, loaders and HTTP client

## Tech Stack

- Swift, UIKit (XIB-based views)
- [RxSwift](https://github.com/ReactiveX/RxSwift)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- XCTest
- Swift Package Manager

## Architecture

Each feature module follows VIPER (View, Interactor, Presenter, Entity/Model, Router):

```
RestaurantApp/
├── App/                    # AppDelegate, SceneDelegate, launch screen
├── Core/
│   ├── Infrastructure/     # HTTPClient protocol, URLSessionHTTPClient
│   └── Services/           # Remote list/detail loaders, NetworkError
└── Modules/
    ├── RestaurantList/     # Protocols, Interactor, Presenter, Router, Views
    └── RestaurantDetail/   # Protocols, Interactor, Presenter, Router, View

RestaurantAppTests/         # Unit tests mirroring the source layout
```

The networking layer sits behind the `HTTPClient` protocol, so loaders and interactors can be tested with stubs.

## Requirements

- Xcode (a version that supports the project's iOS deployment target, currently 26.5)
- An internet connection (API and image access)

## Getting Started

1. Clone the repository.
2. Open `RestaurantApp.xcodeproj` in Xcode.
3. Wait for Swift Package Manager to resolve dependencies.
4. Select the `RestaurantApp` scheme and a simulator.
5. Press `Cmd + R` to run.

## Running Tests

In Xcode, press `Cmd + U`, or from the terminal:

```bash
xcodebuild test \
  -project RestaurantApp.xcodeproj \
  -scheme RestaurantApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Replace the simulator name with one available on your machine.

## API

Base URL: `https://restaurant-api.dicoding.dev`

Images are served from `https://restaurant-api.dicoding.dev/images/medium/<pictureId>`.
