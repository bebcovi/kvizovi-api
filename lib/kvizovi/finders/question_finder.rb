require "kvizovi/finders/base_finder"

module Kvizovi
  module Finders
    class QuestionFinder < BaseFinder
      def all
        dataset.order(:position)
      end

      def find(id)
        find_by_id(id)
      end

      def from_query(query)
        dataset.where {
          (title =~ /#{query}/i) |
          (content.cast(:text) =~ /#{query}/i)
        }
      end
    end
  end
end
