require "kvizovi/models"
require "kvizovi/elasticsearch"

module Kvizovi
  module Mediators
    class Quizzes
      class Create
        def self.call(attrs)
          quiz = Models::Quiz.new(attrs)
          new(quiz).call
        end

        def initialize(quiz)
          @quiz = quiz
        end

        def call
          persist!
          elastic!

          @quiz
        end

        private

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
