require "kvizovi/finders/gameplay_finder"
require "kvizovi/mediators/gameplays/create"

module Kvizovi
  module Mediators
    class Gameplays
      def self.create(attrs)
        Create.call(attrs)
      end

      def initialize(user)
        @user = user
      end

      def search(**options)
        Finders::GameplayFinder.search(**options, user: @user)
      end

      def find(id)
        Finders::GameplayFinder.find(id)
      end

      def destroy_all
        @user.gameplays_dataset.delete
      end
    end
  end
end
