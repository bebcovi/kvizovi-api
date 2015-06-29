require "kvizovi/models"
require "kvizovi/elasticsearch"

module Kvizovi
  module Mediators
    class Questions
      class Create
        def self.call(attrs)
          question = Models::Question.new(attrs)
          new(question).call
        end

        def initialize(question)
          @question = question
        end

        def call
          persist!
          elastic!

          @question
        end

        private

        def persist!
          @question.save
        end

        def elastic!
          ElasticsearchIndex[:quiz].index(@question.quiz)
        end
      end
    end
  end
end
