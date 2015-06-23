require "minitest/hooks"
require_relative "database"
require_relative "factory"
require_relative "elastic"
require_relative "email"
require_relative "profiling"

module TestHelpers
  module Unit
    def self.included(klass)
      klass.include Minitest::Hooks

      klass.include TestHelpers::Database,
                    TestHelpers::Factory,
                    TestHelpers::Elastic,
                    TestHelpers::Email,
                    TestHelpers::Profiling
    end
  end
end
