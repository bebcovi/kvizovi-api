require "kvizovi/mediators/quizzes/validate"
require "kvizovi/models"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Quizzes
      class Create
        def self.call(creator:, **attrs)
          quiz = Models::Quiz.new(creator: creator)
          Utils.mass_assign!(quiz, attrs, PERMITTED_FIELDS)
          new(quiz).call
        end

        def initialize(quiz)
          @quiz = quiz
        end

        def call
          validate!
          persist!
          elastic!

          @quiz
        end

        private

        def validate!
          Validate.call(@quiz)
        end

        def persist!
          @quiz.save
        end

        def elastic!
          ElasticsearchIndex[:quiz].index(@quiz)
        end
      end
    end
  end
end
