# NukiOpenAPIClient

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-lightgray.svg)

A Swift package for integrating with the Nuki Web API using OpenAPI code generation.

## Overview

This package provides a type-safe Swift client for the Nuki Web API, generated from their official OpenAPI specification. It's designed to be used by the opens.rent backend for managing smart lock access.

## Features

- Type-safe API client generated from Nuki's OpenAPI specification
- Async/await support for all API calls
- Comprehensive error handling
- Request/response logging middleware
- Bearer token authentication
- Support for all major Nuki API endpoints

## Requirements

- Swift 5.9+
- macOS 13+ or iOS 16+

## Installation

Add this package to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NukiOpenAPIClient.git", from: "1.0.0")
]
```

## Usage

### Basic Setup

```swift
import NukiOpenAPIClient

// Initialize client with API token
let client = try NukiAPIClient(apiToken: "your-api-token")

// Or initialize without token and set it later
let client = try NukiAPIClient()
client.setAPIToken("your-api-token")
```

### Using the Generated API Client

The client provides access to all Nuki API endpoints through the generated `rawClient` property:

```swift
// List smart locks
let response = try await client.rawClient.SmartlocksResource_get_get(.init())
switch response {
case .ok(let okResponse):
    // Parse the response body using OpenAPIRuntime
    let decoder = JSONDecoder()
    let smartlocks = try decoder.decode(
        [Components.Schemas.Smartlock].self,
        from: okResponse.body.any
    )
    for smartlock in smartlocks {
        print("Smart Lock: \(smartlock.name) (ID: \(smartlock.smartlockId))")
    }
case .unauthorized:
    print("Invalid or missing API token")
case .undocumented(let statusCode, _):
    print("Unexpected status code: \(statusCode)")
}
```

### Available Operations

All API operations are available through the `rawClient` property. Examples:

```swift
// Get account information
client.rawClient.AccountsResource_get_get(.init())

// Get a specific smartlock
client.rawClient.SmartlockResource_get_get(.init(
    path: .init(smartlockId: 12345)
))

// Perform a lock action
client.rawClient.SmartlockActionResource_post_post(.init(
    path: .init(smartlockId: "12345"),
    body: .json(.init(action: 1))
))

// Get smartlock logs
client.rawClient.SmartlockLogsResource_get_get(.init(
    path: .init(smartlockId: 12345),
    query: .init(limit: 50)
))
```

### Response Handling

All responses use the generated OpenAPI types. Response bodies are returned as `HTTPBody` and need to be decoded:

```swift
switch response {
case .ok(let okResponse):
    // Decode the response body
    let decoder = JSONDecoder()
    let data = try await Data(collecting: okResponse.body.any, upTo: 1024 * 1024)
    let result = try decoder.decode(YourExpectedType.self, from: data)
case .unauthorized:
    // Handle authentication error
case .notFound:
    // Handle not found
case .undocumented(let statusCode, _):
    // Handle unexpected status codes
}
```

## Error Handling

The client provides specific error types for common scenarios:

```swift
public enum NukiAPIError: Error {
    case unexpectedResponse(statusCode: Int)
    case authenticationRequired
    case notFound
    case badRequest
    case invalidRequest
}
```

## Configuration

- `openapi.yaml` - The official Nuki OpenAPI specification
- `openapi-generator-config.yaml` - Generator configuration
- `NukiAPIClient.swift` - High-level wrapper around the generated client

## API Coverage

The client supports all major Nuki API endpoints including:

- Smart Locks (list, get, update, delete)
- Lock Actions (lock, unlock, unlatch)
- Smart Lock Logs
- Account Management
- User Management
- Authorizations
- Notifications
- And more...

## Development

### Building

```bash
swift build
```

### Testing

```bash
swift test
```

### Updating the API Specification

1. Download the latest OpenAPI specification from Nuki
2. Replace the `openapi.yaml` file
3. Rebuild the project to regenerate the client code

## Dependencies

- Swift OpenAPI Generator
- Swift OpenAPI Runtime
- Swift OpenAPI URLSession
- Swift HTTP Types

## Continuous Integration

This project uses GitHub Actions for continuous integration:

- **Swift Tests** - Runs on every push and pull request
  - Tests on macOS (latest)
  - Tests on Linux (Ubuntu)
  - Generates test reports
- **Code Review** - Claude AI reviews all pull requests

## License

Apache 2.0