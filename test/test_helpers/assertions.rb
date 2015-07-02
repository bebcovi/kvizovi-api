module TestHelpers
  module Assertions
    def assert_nonempty(klass, object)
      assert_instance_of klass, object
      refute_empty object
    end

    def assert_resource(hash)
      refute_empty hash.fetch("id")
    end
  end
end
