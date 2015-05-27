require "kvizovi/finders/gameplay_finder"

module Kvizovi
  module Mediators
    class Gameplays
      def self.create(attributes)
        ids = attributes.delete(:associations)
        attributes.update(quiz_id: ids.fetch(:quiz), player_ids: ids.fetch(:players))
        Models::Gameplay.create attributes
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
    end
  end
end
