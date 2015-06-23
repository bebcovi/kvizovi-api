require "kvizovi/finders/base_finder"

module Kvizovi
  module Finders
    class QuestionFinder < BaseFinder
      model Models::Question

      def all
        dataset.order(:position)
      end

      def find(id)
        find_by_id(id)
      end
    end
  end
end
