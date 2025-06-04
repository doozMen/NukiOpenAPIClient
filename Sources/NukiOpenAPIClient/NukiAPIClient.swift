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
    
    // MARK: - Example convenience methods
    // These would need to be updated based on the actual generated API
    // For now, we expose the raw client so users can make any API call
    
    /// Example of how to list smartlocks
    /// Usage: 
    /// let response = try await client.rawClient.SmartlocksResource_get_get(.init())
    /// switch response {
    /// case .ok(let okResponse):
    ///     // Handle success
    /// case .unauthorized:
    ///     // Handle auth error
    /// default:
    ///     // Handle other cases
    /// }
}

public enum NukiAPIError: Error {
    case unexpectedResponse(statusCode: Int)
    case authenticationRequired
    case notFound
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