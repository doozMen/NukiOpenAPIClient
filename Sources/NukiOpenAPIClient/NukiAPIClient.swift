import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

public class NukiAPIClient {
    private let client: Client
    private let serverURL: URL
    private var apiToken: String?
    
    public init(apiToken: String? = nil) throws {
        self.serverURL = try Servers.server1()
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
    
    public func listSmartlocks() async throws -> [Components.Schemas.Smartlock] {
        let response = try await client.listSmartlocks()
        switch response {
        case .ok(let okResponse):
            return try okResponse.body.json
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
}

public enum NukiAPIError: Error {
    case unexpectedResponse(statusCode: Int)
    case authenticationRequired
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
        print("[NukiAPI] \(request.method.rawValue) \(request.soar_path ?? "")")
        let (response, responseBody) = try await next(request, body, baseURL)
        print("[NukiAPI] Response: \(response.status)")
        return (response, responseBody)
    }
}