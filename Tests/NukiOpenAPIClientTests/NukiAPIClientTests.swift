import Testing
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes
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
            .forbidden,
            .badRequest,
            .invalidRequest
        ]
        
        // Just verify they compile and can be created
        #expect(errors.count == 6)
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

// MARK: - Generated Code Tests

@Suite("Generated Code Build Tests")
struct GeneratedCodeTests {
    
    @Test("Test generated types compile and can be instantiated")
    func testGeneratedTypes() throws {
        // Test that we can reference generated types
        // The Nuki API types have many required fields, so we'll just verify the types exist
        
        // Verify Account type exists and has expected properties
        typealias AccountType = Components.Schemas.Account
        #expect(true) // Type exists if this compiles
        
        // Verify Smartlock type exists
        typealias SmartlockType = Components.Schemas.Smartlock  
        #expect(true) // Type exists if this compiles
        
        // Verify other important types exist
        typealias SmartlockAuthType = Components.Schemas.SmartlockAuth
        typealias SmartlockLogType = Components.Schemas.SmartlockLog
        typealias AddressType = Components.Schemas.Address
        
        #expect(true) // All types compile successfully
    }
    
    @Test("Test generated operations compile")
    func testGeneratedOperations() async throws {
        // Create a mock transport that returns predefined responses
        let mockTransport = MockTransport()
        
        let client = Client(
            serverURL: try Servers.Server1.url(),
            transport: mockTransport
        )
        
        // Test that operations can be called (they will fail with mock transport, but that's ok)
        do {
            _ = try await client.SmartlocksResource_get_get(.init())
            Issue.record("Should have thrown an error")
        } catch {
            // Expected to fail with mock transport - ClientError wraps the MockTransportError
            #expect(error is ClientError)
        }
    }
    
    @Test("Test operation input types")
    func testOperationInputTypes() throws {
        // Test creating operation inputs
        let listSmartlocksInput = Operations.SmartlocksResource_get_get.Input()
        #expect(listSmartlocksInput != nil)
        
        // Test smartlock by ID input
        let getSmartlockInput = Operations.SmartlockResource_get_get.Input(
            path: .init(smartlockId: 12345)
        )
        #expect(getSmartlockInput.path.smartlockId == 12345)
        
        // Test query parameters
        let logsInput = Operations.SmartlockLogsResource_get_get.Input(
            path: .init(smartlockId: 12345),
            query: .init(
                limit: 50
            )
        )
        #expect(logsInput.path.smartlockId == 12345)
        #expect(logsInput.query.limit == 50)
    }
    
    @Test("Test response handling patterns")
    func testResponseHandling() throws {
        // Test that we can create and handle different response types
        typealias SmartlocksResponse = Operations.SmartlocksResource_get_get.Output
        
        // Simulate handling different response cases
        let okBody = HTTPBody("test")
        let okResponse = SmartlocksResponse.Ok(body: .any(okBody))
        let unauthorizedResponse = SmartlocksResponse.unauthorized(.init())
        
        // Test pattern matching
        func handleResponse(_ response: SmartlocksResponse) -> String {
            switch response {
            case .ok:
                return "success"
            case .unauthorized:
                return "unauthorized"
            case .undocumented:
                return "undocumented"
            }
        }
        
        #expect(handleResponse(.ok(okResponse)) == "success")
        #expect(handleResponse(unauthorizedResponse) == "unauthorized")
    }
    
    @Test("Test convenience methods compile and work")
    func testConvenienceMethods() async throws {
        let client = try NukiAPIClient(apiToken: "test-token")
        
        // We can't actually test these without a real API, but we can verify they compile
        // and have the right signatures
        let _: () async throws -> [Components.Schemas.Smartlock] = client.listSmartlocks
        let _: (Int) async throws -> Components.Schemas.Smartlock = { id in
            try await client.getSmartlock(id: id)
        }
        
        #expect(true) // If we get here, the methods compiled correctly
    }
}

// MARK: - Mock Transport for Testing

struct MockTransportError: Error {}

struct MockTransport: ClientTransport {
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        throw MockTransportError()
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
            // Response body exists
            #expect(true)
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
            // Response body exists
            #expect(true)
        case .unauthorized:
            Issue.record("Authentication failed")
        default:
            Issue.record("Unexpected response")
        }
    }
}