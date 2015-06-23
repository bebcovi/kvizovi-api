require_relative "unit"
require_relative "http"
require_relative "json_api"

module TestHelpers
  module Integration
    def self.included(klass)
      klass.include TestHelpers::Unit,
                    TestHelpers::Http,
                    TestHelpers::JsonApi

    end
  end
end
