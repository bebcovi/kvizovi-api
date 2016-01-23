require "kvizovi"
require "rack/cors"

unless ENV["RACK_ENV"] == "production"
  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => :any
    end
  end
end

run Kvizovi.app
