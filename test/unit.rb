require_relative "setup"
require_relative "test_helpers/factory"
require_relative "test_helpers/misc"

class UnitTest < Minitest::Test
  include Minitest::Hooks

  include TestHelpers::Factory,
          TestHelpers::Misc

  def around
    if defined?(DB)
      DB.transaction(rollback: :always, auto_savepoint: true) { super }
    else
      super
    end

    SimpleMailer.emails_sent.clear if defined?(SimpleMailer)
  end
end
