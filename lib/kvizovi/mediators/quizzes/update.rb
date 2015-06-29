require "kvizovi/elasticsearch"

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
          persist!
          elastic!

          @quiz
        end

        private

        def assign!(attrs)
          @quiz.set(attrs)
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
