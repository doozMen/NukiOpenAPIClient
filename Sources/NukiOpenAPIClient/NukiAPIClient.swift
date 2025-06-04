import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

public class NukiAPIClient {
    private let client: Client
    private let serverURL: URL
    private var apiToken: String?
    
    public init(apiToken: String? = nil) throws {
        self.serverURL = try Servers.Server1.url()
        self.apiToken = apiToken
        
        let transport = URLSessionTransport()
        let middlewares: [ClientMiddleware] = [
            AuthenticationMiddleware(token: apiToken),
            LoggingMiddleware(),
        ]
        self.client = Client(
            serverURL: serverURL,
            transport: transport,
            middlewares: middlewares
        )
    }
    
    public func setAPIToken(_ token: String) {
        self.apiToken = token
    }
    
    // MARK: - Raw Generated Client Access
    
    /// Access the raw generated client for direct API calls
    public var rawClient: Client {
        return client
    }
    
    // MARK: - Convenience Methods
    
    /// List all smartlocks associated with the account
    /// - Returns: Array of smartlocks
    /// - Throws: NukiAPIError if the request fails
    public func listSmartlocks() async throws -> [Components.Schemas.Smartlock] {
        let response = try await client.SmartlocksResource_get_get(.init())
        
        switch response {
        case .ok(let okResponse):
            guard case .any(let httpBody) = okResponse.body else {
                throw NukiAPIError.unexpectedResponse(statusCode: 200)
            }
            let smartlocks = try await JSONDecoder().decode(
                [Components.Schemas.Smartlock].self,
                from: Data(collecting: httpBody, upTo: .max)
            )
            return smartlocks
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .undocumented(statusCode: let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    /// Get a specific smartlock by ID
    /// - Parameter smartlockId: The ID of the smartlock
    /// - Returns: The smartlock details
    /// - Throws: NukiAPIError if the request fails
    public func getSmartlock(id smartlockId: Int) async throws -> Components.Schemas.Smartlock {
        let response = try await client.SmartlockResource_get_get(
            path: .init(smartlockId: smartlockId)
        )
        
        switch response {
        case .ok(let okResponse):
            guard case .any(let httpBody) = okResponse.body else {
                throw NukiAPIError.unexpectedResponse(statusCode: 200)
            }
            let smartlock = try await JSONDecoder().decode(
                Components.Schemas.Smartlock.self,
                from: Data(collecting: httpBody, upTo: .max)
            )
            return smartlock
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .forbidden:
            throw NukiAPIError.forbidden
        case .notFound:
            throw NukiAPIError.notFound
        case .undocumented(statusCode: let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
}

public enum NukiAPIError: Error {
    case unexpectedResponse(statusCode: Int)
    case authenticationRequired
    case notFound
    case forbidden
    case badRequest
    case invalidRequest
}

struct AuthenticationMiddleware: ClientMiddleware {
    let token: String?
    
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let token = token {
            request.headerFields[.authorization] = "Bearer \(token)"
        }
        return try await next(request, body, baseURL)
    }
}

struct LoggingMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        print("[NukiAPI] \(request.method) \(request.path ?? "")")
        let (response, responseBody) = try await next(request, body, baseURL)
        print("[NukiAPI] Response: \(response.status)")
        return (response, responseBody)
    }
}