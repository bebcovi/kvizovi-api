require "kvizovi/mediators/quizzes/validate"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Quizzes
      class Update
        def self.call(quiz, attrs)
          new(quiz).call(attrs)
        end

        def initialize(quiz)
          @quiz = quiz
        end

        def call(attrs)
          assign!(attrs)
          validate!
          persist!
          elastic!

          @quiz
        end

        private

        def assign!(attrs)
          Utils.mass_assign!(@quiz, attrs, PERMITTED_FIELDS)
        end

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
