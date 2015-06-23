require "kvizovi/finders/base_finder"
require "kvizovi/finders/question_finder"

module Kvizovi
  module Finders
    class QuizFinder < BaseFinder
      model Models::Quiz

      def search(q: nil, category: nil, page: nil, **)
        quizzes = dataset.active
        quizzes = new(quizzes).from_query(q) if q
        quizzes = new(quizzes).with_category(category) if category
        quizzes = new(quizzes).paginate(page) if page
        quizzes
      end

      def from_query(query)
        dataset.where {
          (name =~ /#{query}/i) |
          (id =~ QuestionFinder.from_query(query).select(:quiz_id))
        }
      end

      def all
        dataset.reverse(:created_at)
      end

      def find(id)
        find_by_id(id)
      end

      def with_category(category)
        dataset.where(category: category)
      end
    end
  end
end
