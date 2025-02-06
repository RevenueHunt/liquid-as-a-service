require 'sinatra'
require 'liquid'
require 'json'
require 'base64'
require 'openssl'

# Configure Liquid
Liquid::Template.error_mode = :strict

# Basic health check
get '/' do
  halt 405, 'needs to be post'
end

post '/' do
  rendered = 'SOMETHING WENT WRONG IN THE TEMPLATE'
  error = nil
  
  # Read request body
  body = request.body.read
  
  # Authenticate request
  halt 401, 'wrong hmac' unless authenticate(body)
  
  begin
    # Parse JSON body
    parsed_body = JSON.parse(body)
    data = parsed_body['data']
    template = parsed_body['template']
    
    # Render template
    liquid_template = Liquid::Template.parse(template)
    rendered = liquid_template.render(data)
  rescue JSON::ParserError => e
    error = "JSON parsing error: #{e.message}"
  rescue Liquid::SyntaxError => e
    error = "Template syntax error: #{e.message}"
  rescue StandardError => e
    error = "Error: #{e.message}"
  end
  
  # Return result
  content_type :json
  { rendered: rendered, error: error }.delete_if { |_, value| value.nil? }.to_json
end

not_found do
  '404'
end

def authenticate(body)
  secret = ENV['SECRET']
  hmac = request.env["HTTP_X_HMAC_SHA256"]
  return false if hmac.nil?
  
  calculated_hmac = Base64.strict_encode64(
    OpenSSL::HMAC.digest('sha256', secret, body)
  )
  calculated_hmac == hmac
end 