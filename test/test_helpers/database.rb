module TestHelpers
  module Database
    def around
      if defined?(DB)
        DB.transaction(rollback: :always, auto_savepoint: true) { super }
      else
        super
      end
    end

    def log
      require "logger"
      DB.logger = Logger.new(STDOUT)
      yield
      DB.logger = Logger.new(nil)
    end

    def invalid(&block)
      assert_raises(Kvizovi::Error::ValidationFailed, &block)
    end
  end
end
