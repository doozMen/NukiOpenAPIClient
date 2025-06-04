# NukiOpenAPIClient

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

### Listing Smart Locks

```swift
do {
    let smartlocks = try await client.listSmartlocks()
    for smartlock in smartlocks {
        print("Smart Lock: \(smartlock.name) (ID: \(smartlock.smartlockId))")
    }
} catch NukiAPIError.authenticationRequired {
    print("Invalid or missing API token")
} catch {
    print("Error: \(error)")
}
```

### Getting a Specific Smart Lock

```swift
do {
    let smartlock = try await client.getSmartlock(smartlockId: 12345)
    print("Smart Lock: \(smartlock.name)")
    print("Battery Critical: \(smartlock.state?.batteryCritical ?? false)")
} catch NukiAPIError.notFound {
    print("Smart lock not found")
} catch {
    print("Error: \(error)")
}
```

### Performing Lock Actions

```swift
do {
    // Lock the door
    try await client.lockAction(
        smartlockId: 12345,
        action: 1 // 1 = lock, 2 = unlock, 3 = unlatch
    )
    print("Lock action completed")
} catch NukiAPIError.badRequest {
    print("Invalid action")
} catch {
    print("Error: \(error)")
}
```

### Getting Smart Lock Logs

```swift
do {
    let logs = try await client.getSmartlockLogs(
        smartlockId: 12345,
        limit: 50
    )
    for log in logs {
        print("Action: \(log.action) at \(log.date)")
    }
} catch {
    print("Error: \(error)")
}
```

### Account Management

```swift
do {
    let account = try await client.getAccount()
    print("Account ID: \(account.accountId)")
    print("Email: \(account.email)")
} catch {
    print("Error: \(error)")
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

## License

Apache 2.0