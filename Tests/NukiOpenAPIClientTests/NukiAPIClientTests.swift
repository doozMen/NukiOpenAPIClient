import XCTest
@testable import NukiOpenAPIClient

final class NukiAPIClientTests: XCTestCase {
    func testClientInitialization() throws {
        XCTAssertNoThrow(try NukiAPIClient())
        
        let clientWithToken = try NukiAPIClient(apiToken: "test-token")
        XCTAssertNotNil(clientWithToken)
    }
}