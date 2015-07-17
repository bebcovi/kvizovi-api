require "roda"
require "kvizovi/configuration/refile"

require "kvizovi/authorization"
require "kvizovi/serializer"
require "kvizovi/mediators/account"
require "kvizovi/error"
require "kvizovi/utils"

require "rack/deflater"

module Kvizovi
  class App < Roda
    plugin :all_verbs
    plugin :json, classes: Serializer::CLASSES, serializer: Serializer, include_request: true
    plugin :json_parser
    plugin :symbolized_params
    plugin :error_handler
    plugin :multi_route
    plugin :heartbeat
    plugin :not_found

    unless ENV["RACK_ENV"] == "production"
      plugin :default_headers, "Access-Control-Allow-Origin"=>"*"
    end

    use Rack::Deflater

    route do |r|
      r.multi_route

      r.on Refile.mount_point do
        r.run Refile::App
      end
    end

    def current_user
      Mediators::Account.authenticate(:token, authorization.token)
    end

    def authorization
      Authorization.new(env["HTTP_AUTHORIZATION"])
    end

    def resource(name)
      Utils.resource(params, name)
    end

    def required(name)
      Utils.require_param(params, name)
    end

    def uploaded_file(hash, key)
      Utils.uploaded_file(hash, key)
    end

    error do |error|
      if Kvizovi::Error === error
        response.status = error.status
        error
      else
        raise error
      end
    end

    not_found do
      raise Kvizovi::Error::PageNotFound, request.path
    end
  end
end

require "kvizovi/routes/account"
require "kvizovi/routes/quizzes"
require "kvizovi/routes/gameplays"
require "kvizovi/routes/contact"
