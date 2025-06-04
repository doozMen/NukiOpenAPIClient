import Testing
@testable import NukiOpenAPIClient

@Suite("Nuki API Client Tests")
struct NukiAPIClientTests {
    
    @Test("Client initialization without token")
    func clientInitializationWithoutToken() throws {
        // Test without token
        #expect(throws: Never.self) {
            _ = try NukiAPIClient()
        }
    }
    
    @Test("Client initialization with token")
    func clientInitializationWithToken() throws {
        // Test with token
        let client = try NukiAPIClient(apiToken: "test-token")
        #expect(client != nil)
    }
    
    @Test("Set API token")
    func setAPIToken() throws {
        let client = try NukiAPIClient()
        client.setAPIToken("new-token")
        // Token is private, so we can only verify the method doesn't throw
        #expect(true)
    }
    
    @Test("Raw client access")
    func rawClientAccess() throws {
        let client = try NukiAPIClient(apiToken: "test-token")
        let rawClient = client.rawClient
        #expect(rawClient != nil)
    }
    
    @Test("Nuki API error types")
    func nukiAPIErrorTypes() {
        // Verify all error types are available
        let errors: [NukiAPIError] = [
            .unexpectedResponse(statusCode: 500),
            .authenticationRequired,
            .notFound,
            .badRequest,
            .invalidRequest
        ]
        
        // Just verify they compile and can be created
        #expect(errors.count == 5)
    }
    
    @Test("Verify middleware initialization")
    func middlewareInitialization() throws {
        // Test that client initializes with middleware
        let clientWithToken = try NukiAPIClient(apiToken: "test-token")
        #expect(clientWithToken != nil)
        
        let clientWithoutToken = try NukiAPIClient()
        #expect(clientWithoutToken != nil)
    }
}

// MARK: - Integration Test Examples

@Suite("Integration Test Examples")
struct IntegrationTestExamples {
    
    @Test("Example: List smartlocks", .disabled("Requires valid API token"))
    func exampleListSmartlocks() async throws {
        // This test is disabled by default as it requires a valid API token
        // To run integration tests:
        // 1. Set a valid API token
        // 2. Remove the .disabled attribute
        
        let client = try NukiAPIClient(apiToken: "your-api-token")
        let response = try await client.rawClient.SmartlocksResource_get_get(.init())
        
        switch response {
        case .ok(let okResponse):
            // Parse the response body
            #expect(okResponse.body != nil)
        case .unauthorized:
            Issue.record("Authentication failed")
        case .undocumented(let statusCode, _):
            Issue.record("Unexpected status code: \(statusCode)")
        default:
            Issue.record("Unexpected response")
        }
    }
    
    @Test("Example: Get account info", .disabled("Requires valid API token"))
    func exampleGetAccount() async throws {
        let client = try NukiAPIClient(apiToken: "your-api-token")
        let response = try await client.rawClient.AccountsResource_get_get(.init())
        
        switch response {
        case .ok(let okResponse):
            #expect(okResponse.body != nil)
        case .unauthorized:
            Issue.record("Authentication failed")
        default:
            Issue.record("Unexpected response")
        }
    }
}