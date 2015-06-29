require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Gameplays
      class Validate
        def self.call(gameplay)
          new(gameplay).call
        end

        def initialize(gameplay)
          @gameplay = gameplay
        end

        def call
          validate!
        end

        private

        def validate!
          @gameplay.validates_presence [:quiz_snapshot, :answers, :started_at, :finished_at]

          Utils.valid!(@gameplay)
        end
      end
    end
  end
end
