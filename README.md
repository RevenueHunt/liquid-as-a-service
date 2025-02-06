# Liquid Template Rendering Service

A secure microservice that renders Liquid templates with provided data. Built with Ruby and Sinatra, this service authenticates requests using HMAC SHA-256 and returns rendered templates in JSON format.

## Features

- Liquid template rendering
- HMAC SHA-256 authentication
- JSON request/response format
- Docker support
- Error handling for template and JSON parsing

## Prerequisites

- Ruby 3.4.1
- Docker (optional)

## Installation

### Local Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Set the secret key environment variable:
   ```bash
   export SECRET=your_secret_key
   ```
4. Start the server:
   ```bash
   bundle exec ruby server.rb
   ```

### Docker Setup

1. Build the Docker image:
   ```bash
   docker build -t liquid-renderer .
   ```
2. Run the container:
   ```bash
   docker run -p 4567:4567 -e SECRET=your_secret_key liquid-renderer
   ```

## Usage

Send POST requests to the root endpoint (`/`) with the following:

### Example Using Curl

```bash
# Create request body
BODY='{
  "template": "Hello {{ name }}!",
  "data": {
    "name": "World"
  }
}'

# Generate HMAC signature (using bash and openssl)
SECRET="your_secret_key"
SIGNATURE=$(echo -n "$BODY" | openssl dgst -sha256 -hmac "$SECRET" -binary | base64)

# Send request
curl -X POST http://localhost:4567 \
  -H "Content-Type: application/json" \
  -H "X-HMAC-SHA256: $SIGNATURE" \
  -d "$BODY"
```

Expected response:
```json
{
  "rendered": "Hello World!"
}
```

### Headers

- `Content-Type: application/json`
- `X-HMAC-SHA256`: Base64-encoded HMAC signature of the request body

### Request Body

```json
{
  "template": "Hello {{ name }}!",
  "data": {
    "name": "World"
  }
}
```

### Response Format

Success:
```json
{
  "rendered": "Hello World!"
}
```

Error:

```
json
{
  "rendered": "SOMETHING WENT WRONG IN THE TEMPLATE",
  "error": "Error message details"
}
```
### Generating HMAC Signature

Example in Ruby:

```ruby
require 'base64'
require 'openssl'
body = request_body_json_string
secret = ENV['SECRET']
hmac = Base64.strict_encode64(
OpenSSL::HMAC.digest('sha256', secret, body)
)
```

## Error Handling

The service handles and returns appropriate error messages for:
- JSON parsing errors
- Liquid template syntax errors
- Authentication failures
- General runtime errors

## Security Considerations

- Keep your secret key secure and never commit it to version control
- Use HTTPS in production
- Be cautious with user-provided templates as they can potentially access sensitive data
- Consider implementing rate limiting for production use

## Development

The service uses:
- `sinatra` for the web framework
- `liquid` for template rendering
- `puma` as the web server

## License

This project is licensed under the BSD 3-Clause License.
