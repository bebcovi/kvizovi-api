require "kvizovi/finders/question_finder"

module Kvizovi
  module Mediators
    class Questions
      def initialize(quiz)
        @quiz = quiz
      end

      def all
        Finders::QuestionFinder.new(@quiz.questions_dataset).all
      end

      def find(id)
        Finders::QuestionFinder.new(all).find(id)
      end

      def create(attrs)
        @quiz.add_question(attrs)
      end

      def update(id, attrs)
        find(id).update(attrs)
      end

      def destroy(id)
        find(id).destroy
      end
    end
  end
end
