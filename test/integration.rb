require_relative "unit"
require_relative "test_helpers/http"
require_relative "test_helpers/json_api"

require "kvizovi"

Kvizovi::App.plugin(:not_found) { raise "404 not found" }
SimpleMailer.test_mode!
BCrypt::Engine.cost = 1
Refile.logger = Logger.new(nil)

class IntegrationTest < UnitTest
  include TestHelpers::Http,
          TestHelpers::JsonApi
end
