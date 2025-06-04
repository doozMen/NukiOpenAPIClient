# Converting Swagger 2.0 to OpenAPI 3.0

The Nuki API specification is provided in Swagger 2.0 format, but Swift OpenAPI Generator requires OpenAPI 3.0.x or 3.1.x format. This document explains how to convert between these formats.

## Why Conversion is Needed

- **Nuki API**: Provides specification in Swagger 2.0 format at https://api.nuki.io/static/swagger/swagger.json
- **Swift OpenAPI Generator**: Requires OpenAPI 3.0.x or 3.1.x format
- **Key Differences**: Different structure for security definitions, request/response definitions, and parameter specifications

## Conversion Tool

We use the `swagger2openapi` npm package for conversion. This tool is well-maintained and handles most conversion cases automatically.

### Installation

```bash
npm install -g swagger2openapi
```

### Basic Usage

```bash
# Download the Nuki Swagger spec
curl -o swagger.json https://api.nuki.io/static/swagger/swagger.json

# Convert to OpenAPI 3.0
swagger2openapi swagger.json -o openapi.json
```

### Common Issues and Fixes

During conversion, you may encounter these issues:

1. **Invalid "int" type**: Swagger 2.0 uses "int" but OpenAPI 3.0 requires "integer"
   - The converter usually handles this automatically

2. **Missing security schemes**: If the spec references security schemes that aren't defined
   - Add missing security scheme definitions

3. **Server URL**: OpenAPI 3.0 requires explicit server definitions
   - The converter adds these based on the Swagger 2.0 host/basePath

### Validation

After conversion, validate the OpenAPI spec:

```bash
swagger2openapi --validate openapi.json
```

## Alternative Tools

If `swagger2openapi` doesn't work for your use case, consider:

1. **Online Converters**:
   - [Swagger Editor](https://editor.swagger.io/) - Can import Swagger 2.0 and export OpenAPI 3.0
   - [APIMatic Transformer](https://www.apimatic.io/transformer/)

2. **Other CLI Tools**:
   - [openapi-generator-cli](https://github.com/OpenAPITools/openapi-generator)
   - Custom scripts using libraries like `js-yaml`

## Manual Adjustments

Sometimes manual adjustments are needed after conversion:

1. **Response Content Types**: Ensure response content types are properly specified
2. **Parameter Locations**: Verify path/query/header parameters are correctly placed
3. **Security Definitions**: Check that security schemes are properly converted

## Keeping Up to Date

When updating the Nuki API specification:

1. Download the latest Swagger 2.0 spec from Nuki
2. Run the conversion process
3. Test that the generated Swift client still works correctly
4. Update any custom modifications if needed