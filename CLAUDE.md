# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Building
```bash
swift build
```

### Testing
```bash
swift test
```

### Running a specific test
```bash
swift test --filter NukiAPIClientTests
```

## Architecture

This is a Swift package that provides a type-safe client for the Nuki Web API using Apple's Swift OpenAPI Generator.

### Key Components

1. **OpenAPI Specification**: `Sources/NukiOpenAPIClient/openapi.yaml` - Currently a placeholder that needs to be replaced with the actual Nuki API spec from https://developer.nuki.io

2. **Code Generation**: The package uses Swift OpenAPI Generator plugin to automatically generate client code during build from the OpenAPI spec. Configuration is in `openapi-generator-config.yaml`.

3. **Client Wrapper**: `NukiAPIClient.swift` provides a high-level wrapper around the generated client with:
   - Bearer token authentication via `AuthenticationMiddleware`
   - Request/response logging via `LoggingMiddleware`
   - Error handling that converts OpenAPI responses to Swift errors

### Important Notes

- The OpenAPI spec (`openapi.yaml`) contains the official Nuki API specification (v3.9.0)
- Generated code is created at build time by the Swift OpenAPI Generator plugin - no manual generation needed
- The package supports macOS 13+ and iOS 16+
- Authentication uses Bearer tokens passed to the `NukiAPIClient` initializer
- The generated client code is in `.build/plugins/outputs/nukiopenapiclient/NukiOpenAPIClient/destination/OpenAPIGenerator/GeneratedSources/`
- All API responses use `.any(HTTPBody)` format and need to be decoded from the response body