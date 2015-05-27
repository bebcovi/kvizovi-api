require "rack/test"
require "json"
require "kvizovi"

module TestHelpers
  module Http
    include Rack::Test::Methods

    def app
      Kvizovi.app
    end

    def body
      JSON.parse(last_response.body)
    end

    def status
      last_response.status
    end

    [:post, :put, :patch, :delete].each do |http_method|
      alias_method :"#{http_method}_original", http_method
      define_method(http_method) do |uri, params = {}, env = {}, &block|
        env["CONTENT_TYPE"] = "application/json"
        super(uri, params.to_json, env, &block)
      end
    end

    def token_auth(token)
      {"HTTP_AUTHORIZATION" => "Token token=\"#{token}\""}
    end

    def basic_auth(username, password)
      {"HTTP_AUTHORIZATION" => "Basic #{["#{username}:#{password}"].pack("m*")}"}
    end
  end
end
