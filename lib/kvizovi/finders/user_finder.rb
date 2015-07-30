require "kvizovi/finders/base_finder"

module Kvizovi
  module Finders
    class UserFinder < BaseFinder
      model Models::User

      def typeahead(q:, count: 5)
        dataset.where{name.ilike("%#{q}%")}.limit(count)
      end
    end
  end
end
