require "kvizovi/mediators/questions/validate"
require "kvizovi/models"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Questions
      class Create
        def self.call(quiz:, **attrs)
          question = Models::Question.new(quiz: quiz)
          Utils.mass_assign!(question, attrs, PERMITTED_FIELDS)
          new(question).call
        end

        def initialize(question)
          @question = question
        end

        def call
          validate!
          persist!
          elastic!

          @question
        end

        private

        def validate!
          Validate.call(@question)
        end

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
