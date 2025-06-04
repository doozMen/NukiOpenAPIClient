# Generating a Client in a Swift Package

> Build `GreetingServiceClient`—a Swift API client for a service returning a personalized greeting.  
> Uses [Swift OpenAPI Generator](https://swiftpackageindex.com/apple/swift-openapi-generator) plugin.  
> 📦 Swift 5.9 · 🕒 20 mins

---

## Step 0: Try the Result Example

A full working example is available here:

```bash
git clone https://github.com/apple/swift-openapi-generator
cd swift-openapi-generator/Examples/hello-world-urlsession-client-example
```

---

## Step 1: (Optional) Run Local Test Server

To test the generated client:

```bash
git clone https://github.com/apple/swift-openapi-generator
cd swift-openapi-generator/Examples/hello-world-vapor-server-example
swift run HelloWorldVaporServer
```

Test with:

```bash
curl 'localhost:8080/api/greet?name=Jane'
# { "message": "Hello, Jane" }
```

---

## Step 2: Create a New Swift Package

```bash
mkdir GreetingServiceClient
cd GreetingServiceClient
swift package init --type executable
open Package.swift
```

---

## Step 3: Add OpenAPI Spec and Configuration

### `Sources/openapi.yaml`

```yaml
openapi: '3.1.0'
info:
  title: GreetingService
  version: 1.0.0
servers:
  - url: https://example.com/api
    description: Example service deployment
paths:
  /greet:
    get:
      operationId: getGreeting
      parameters:
        - name: name
          required: false
          in: query
          description: The name used in the returned greeting.
          schema:
            type: string
      responses:
        '200':
          description: A success response with a greeting.
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Greeting'
components:
  schemas:
    Greeting:
      type: object
      properties:
        message:
          type: string
```

### `openapi-generator-config.yaml`

```yaml
accessModifier: internal
```

---

## Step 4: Edit `Package.swift`

- Add dependencies:

```swift
.package(url: "https://github.com/apple/swift-openapi-generator", from: "1.8.0"),
```

- Add plugins and targets:

```swift
.target(
  name: "GreetingServiceClient",
  dependencies: [
    .product(name: "OpenAPIRuntime", package: "swift-openapi-generator"),
    .product(name: "OpenAPIURLSession", package: "swift-openapi-generator")
  ],
  plugins: [
    .plugin(name: "OpenAPIGeneratorPlugin", package: "swift-openapi-generator")
  ]
)
```

---

## Step 5: Use the Generated Client

### `Sources/GreetingServiceClient/main.swift`

```swift
import OpenAPIRuntime
import OpenAPIURLSession

let client = Client(
  serverURL: try Servers.Server2.url(), // or .Server1 for prod
  transport: URLSessionTransport()
)

let response = try await client.getGreeting(query: .init(name: "CLI"))

// Version A: switch style
switch response {
case .ok(let okResponse):
  print(okResponse)
}

// Version B: unwrapping
print(try response.ok.body.json.message)
```

---

## Next: Explore Further

You can also check the companion guide:

📘 [Generating a client in an Xcode project](https://swiftpackageindex.com/apple/swift-openapi-generator/1.8.0/tutorials/swift-openapi-generator/clientxcode)