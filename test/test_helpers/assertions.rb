module TestHelpers
  module Assertions
    def assert_nonempty(klass, object)
      assert_instance_of klass, object
      refute_empty object
    end
  end
end
