require "kvizovi/mediators/questions"
require "kvizovi/mediators/gameplays"
require "kvizovi/elasticsearch"

module Kvizovi
  module Mediators
    class Quizzes
      class Destroy
        def self.call(quiz)
          new(quiz).call
        end

        def initialize(quiz)
          @quiz = quiz
        end

        def call
          delete!
          elastic!

          @quiz
        end

        private

        def delete!
          @quiz.model.db.transaction do
            Questions.new(@quiz).destroy_all
            Gameplays.new(@quiz).destroy_all
            @quiz.destroy
          end
        end

        def elastic!
          ElasticsearchIndex[:quiz].delete(@quiz)
        end
      end
    end
  end
end

