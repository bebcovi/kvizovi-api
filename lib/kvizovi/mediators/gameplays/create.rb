require "kvizovi/models"

module Kvizovi
  module Mediators
    class Gameplays
      class Create
        def self.call(attrs)
          ids = attrs.delete(:associations)
          attrs.update(quiz_id: ids.fetch(:quiz), player_ids: ids.fetch(:players))
          gameplay = Models::Gameplay.new(attrs)
          new(gameplay).call
        end

        def initialize(gameplay)
          @gameplay = gameplay
        end

        def call
          persist!

          @gameplay
        end

        private

        def persist!
          @gameplay.save
        end
      end
    end
  end
end
