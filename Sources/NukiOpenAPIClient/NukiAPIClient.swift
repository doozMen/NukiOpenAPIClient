import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

/// A high-level Swift client for the Nuki Web API.
/// 
/// This client provides a convenient wrapper around the auto-generated OpenAPI client,
/// with built-in authentication, logging, and error handling.
///
/// ## Topics
///
/// ### Essentials
/// - ``init(apiToken:)``
/// - ``setAPIToken(_:)``
/// - ``rawClient``
///
/// ### Convenience Methods
/// - ``listSmartlocks()``
/// - ``getSmartlock(id:)``
///
/// ### Error Handling
/// - ``NukiAPIError``
public class NukiAPIClient {
    private let client: Client
    private let serverURL: URL
    private var apiToken: String?
    
    /// Initializes a new Nuki API client.
    /// 
    /// - Parameter apiToken: Optional Bearer token for authentication. Can be set later using ``setAPIToken(_:)``.
    /// - Throws: An error if the server URL cannot be constructed.
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
    
    /// Updates the API token used for authentication.
    /// 
    /// - Parameter token: The new Bearer token.
    /// - Note: This only affects the stored token reference. The middleware uses the token
    ///   provided during initialization.
    public func setAPIToken(_ token: String) {
        self.apiToken = token
    }
    
    // MARK: - Raw Generated Client Access
    
    /// Provides access to the raw generated OpenAPI client.
    /// 
    /// Use this property to make direct API calls using the generated client methods.
    /// 
    /// ## Example
    /// ```swift
    /// let response = try await client.rawClient.SmartlocksResource_get_get(.init())
    /// ```
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

/// Errors that can occur when using the Nuki API client.
public enum NukiAPIError: Error {
    /// The server returned an unexpected HTTP status code.
    case unexpectedResponse(statusCode: Int)
    /// Authentication is required but no valid token was provided.
    case authenticationRequired
    /// The requested resource was not found.
    case notFound
    /// Access to the resource is forbidden.
    case forbidden
    /// The request was malformed or invalid.
    case badRequest
    /// The request parameters were invalid.
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