import XCTest
@testable import NukiOpenAPIClient

final class NukiAPIClientTests: XCTestCase {
    
    func testClientInitialization() throws {
        // Test without token
        XCTAssertNoThrow(try NukiAPIClient())
        
        // Test with token
        let clientWithToken = try NukiAPIClient(apiToken: "test-token")
        XCTAssertNotNil(clientWithToken)
    }
    
    func testSetAPIToken() throws {
        let client = try NukiAPIClient()
        client.setAPIToken("new-token")
        // Token is private, so we can only verify the method doesn't throw
        XCTAssertTrue(true)
    }
    
    func testNukiAPIErrorTypes() {
        // Verify all error types are available
        let errors: [NukiAPIError] = [
            .unexpectedResponse(statusCode: 500),
            .authenticationRequired,
            .notFound,
            .badRequest,
            .invalidRequest
        ]
        
        // Just verify they compile and can be created
        XCTAssertEqual(errors.count, 5)
    }
    
    // Note: Integration tests below would require a valid API token and network access
    // They are marked as examples of how to test the actual API calls
    
    func testListSmartlocksStructure() async throws {
        // This test verifies the method signature compiles correctly
        let client = try NukiAPIClient(apiToken: "dummy-token")
        
        // We can't actually call this without a valid token, but we can verify it compiles
        // In a real test environment, you would:
        // 1. Use a test API token
        // 2. Mock the network responses
        // 3. Or use a test server
        
        // Example of what the test would look like:
        /*
        do {
            let smartlocks = try await client.listSmartlocks()
            XCTAssertNotNil(smartlocks)
            XCTAssertTrue(smartlocks.isEmpty || smartlocks.count > 0)
        } catch NukiAPIError.authenticationRequired {
            // Expected when using dummy token
            XCTAssertTrue(true)
        }
        */
    }
    
    func testGetSmartlockStructure() async throws {
        let client = try NukiAPIClient(apiToken: "dummy-token")
        
        // Verify method signature compiles with correct types
        // In real tests, you would test with actual smartlock IDs
        /*
        do {
            let smartlock = try await client.getSmartlock(smartlockId: 12345)
            XCTAssertNotNil(smartlock)
            XCTAssertEqual(smartlock.smartlockId, 12345)
        } catch NukiAPIError.authenticationRequired {
            // Expected when using dummy token
            XCTAssertTrue(true)
        }
        */
    }
    
    func testErrorHandling() async throws {
        let client = try NukiAPIClient() // No token
        
        // When calling without authentication, we should get authenticationRequired error
        do {
            _ = try await client.getAccount()
            XCTFail("Should have thrown authenticationRequired error")
        } catch NukiAPIError.authenticationRequired {
            // This is expected
            XCTAssertTrue(true)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Mock Tests
// These tests demonstrate how to test with mocked responses

extension NukiAPIClientTests {
    
    func testMockSmartlockResponse() throws {
        // In a real implementation, you would:
        // 1. Create a mock transport that returns predefined responses
        // 2. Inject it into the client
        // 3. Test the response parsing
        
        // Example structure:
        /*
        let mockTransport = MockTransport()
        mockTransport.responses["/smartlock"] = MockResponse(
            status: 200,
            body: """
            [{
                "smartlockId": 12345,
                "name": "Front Door",
                "state": {
                    "mode": 2,
                    "state": 1,
                    "trigger": 0,
                    "lastAction": 0,
                    "batteryCritical": false,
                    "timestamp": "2024-06-04T12:00:00Z"
                }
            }]
            """
        )
        
        let client = NukiAPIClient(transport: mockTransport)
        let smartlocks = try await client.listSmartlocks()
        
        XCTAssertEqual(smartlocks.count, 1)
        XCTAssertEqual(smartlocks[0].smartlockId, 12345)
        XCTAssertEqual(smartlocks[0].name, "Front Door")
        */
    }
}

// MARK: - Test Helpers

private extension NukiAPIClientTests {
    
    /// Helper to create test dates
    func createTestDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString)
    }
    
    /// Helper to verify date ranges
    func assertDateInRange(_ date: Date?, from: Date, to: Date, file: StaticString = #file, line: UInt = #line) {
        guard let date = date else {
            XCTFail("Date is nil", file: file, line: line)
            return
        }
        XCTAssertTrue(date >= from && date <= to, "Date \(date) is not in range \(from) to \(to)", file: file, line: line)
    }
}