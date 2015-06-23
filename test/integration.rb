require_relative "setup"
require_relative "test_helpers/integration"

require "kvizovi"

Kvizovi::App.plugin(:not_found) { raise "404 not found" }
SimpleMailer.test_mode!
BCrypt::Engine.cost = 1
Refile.logger = Logger.new(nil)
