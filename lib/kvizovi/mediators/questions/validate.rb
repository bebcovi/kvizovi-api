require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Questions
      class Validate
        def self.call(question)
          new(question).call
        end

        def initialize(question)
          @question = question
        end

        def call
          validate!
        end

        private

        def validate!
          @question.validates_presence [:kind, :title, :content, :position]
          @question.validates_unique [:position, :quiz_id]

          Utils.valid!(@question)
        end
      end
    end
  end
end
