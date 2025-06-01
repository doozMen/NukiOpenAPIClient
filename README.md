# NukiOpenAPIClient

A Swift package for integrating with the Nuki Web API using OpenAPI code generation.

## Overview

This package provides a type-safe Swift client for the Nuki Web API, generated from their OpenAPI specification. It's designed to be used by the opens.rent backend for managing smart lock access.

## Setup

1. Replace the placeholder `openapi.yaml` with the actual Nuki API specification from https://developer.nuki.io
2. The OpenAPI generator will automatically create the client code during build

## Usage

```swift
import NukiOpenAPIClient

let client = try NukiAPIClient(apiToken: "your-api-token")
let smartlocks = try await client.listSmartlocks()
```

## Configuration

- `openapi.yaml` - The OpenAPI specification (currently a placeholder)
- `openapi-generator-config.yaml` - Generator configuration
- `NukiAPIClient.swift` - High-level wrapper around the generated client

## Dependencies

- Swift OpenAPI Generator
- Swift OpenAPI Runtime
- Swift OpenAPI URLSession