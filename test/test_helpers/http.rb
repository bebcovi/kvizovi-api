require "rack/test"
require "kvizovi"

module TestHelpers
  module Http
    include Rack::Test::Methods

    def app
      Kvizovi.app
    end

    [:post, :put, :patch, :delete].each do |http_method|
      alias_method :"#{http_method}_original", http_method
      define_method(http_method) do |uri, params = {}, env = {}|
        env["CONTENT_TYPE"] = "application/json"
        super(uri, params.to_json, env) { |response| (@responses ||= []) << response}
      end
    end

    def token_auth(token)
      {"HTTP_AUTHORIZATION" => "Token token=\"#{token}\""}
    end

    def basic_auth(username, password)
      {"HTTP_AUTHORIZATION" => "Basic #{["#{username}:#{password}"].pack("m*")}"}
    end

    def image
      Rack::Test::UploadedFile.new("test/fixtures/image.jpg", "image/jpeg")
    end
  end
end
