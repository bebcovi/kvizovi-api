require "kvizovi/finders/quiz_finder"

module Kvizovi
  module Mediators
    class Quizzes
      def self.search(**options)
        Finders::QuizFinder.search(**options)
      end

      def self.find(id)
        Finders::QuizFinder.find(id)
      end

      def initialize(user)
        @user = user
      end

      def all
        Finders::QuizFinder.new(@user.quizzes_dataset).all
      end

      def find(id)
        Finders::QuizFinder.new(all).find(id)
      end

      def create(attrs)
        @user.add_quiz(attrs)
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
