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
    
    // MARK: - Smartlock Operations
    
    public func listSmartlocks(authIds: Bool? = nil) async throws -> [Components.Schemas.Smartlock] {
        let response = try await client.SmartlocksResource_get_get(.init(
            query: .init(authIds: authIds)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let smartlocks):
                return smartlocks
            }
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    public func getSmartlock(smartlockId: Int64) async throws -> Components.Schemas.Smartlock {
        let response = try await client.SmartlockResource_get_get(.init(
            path: .init(smartlockId: smartlockId)
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let smartlock):
                return smartlock
            }
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .notFound:
            throw NukiAPIError.notFound
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    public func updateSmartlock(smartlockId: Int64, smartlock: Components.Schemas.Smartlock) async throws {
        let response = try await client.SmartlockResource_post_post(.init(
            path: .init(smartlockId: smartlockId),
            body: .json(smartlock)
        ))
        
        switch response {
        case .noContent:
            return
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    // MARK: - Smartlock Actions
    
    public func lockAction(smartlockId: Int64, action: Operations.SmartlockActionResource_post_post.Input.Body.jsonPayload.actionPayload) async throws {
        let response = try await client.SmartlockActionResource_post_post(.init(
            path: .init(smartlockId: smartlockId),
            body: .json(.init(action: action))
        ))
        
        switch response {
        case .noContent:
            return
        case .badRequest:
            throw NukiAPIError.badRequest
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .unprocessableEntity:
            throw NukiAPIError.invalidRequest
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    // MARK: - Smartlock Logs
    
    public func getSmartlockLogs(
        smartlockId: Int64,
        accountUserId: Int32? = nil,
        fromDate: String? = nil,
        toDate: String? = nil,
        action: Operations.SmartlockLogsResource_get_get.Input.Query.actionPayload? = nil,
        id: String? = nil,
        limit: Int32? = nil
    ) async throws -> [Components.Schemas.SmartlockLog] {
        let response = try await client.SmartlockLogsResource_get_get(.init(
            path: .init(smartlockId: smartlockId),
            query: .init(
                accountUserId: accountUserId,
                fromDate: fromDate,
                toDate: toDate,
                action: action,
                id: id,
                limit: limit
            )
        ))
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let logs):
                return logs
            }
        case .badRequest:
            throw NukiAPIError.badRequest
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
    
    // MARK: - Account Operations
    
    public func getAccount() async throws -> Components.Schemas.MyAccount {
        let response = try await client.AccountsResource_get_get(.init())
        
        switch response {
        case .ok(let okResponse):
            switch okResponse.body {
            case .json(let account):
                return account
            }
        case .unauthorized:
            throw NukiAPIError.authenticationRequired
        case .undocumented(let statusCode, _):
            throw NukiAPIError.unexpectedResponse(statusCode: statusCode)
        }
    }
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