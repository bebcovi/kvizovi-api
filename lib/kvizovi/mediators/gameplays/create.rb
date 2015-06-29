require "kvizovi/mediators/gameplays/validate"
require "kvizovi/models"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Gameplays
      class Create
        def self.call(attrs)
          ids = attrs.delete(:associations)
          gameplay = Models::Gameplay.new(
            quiz_id: ids.fetch(:quiz),
            player_ids: ids.fetch(:players),
          )
          Utils.mass_assign!(gameplay, attrs, PERMITTED_FIELDS)
          new(gameplay).call
        end

        def initialize(gameplay)
          @gameplay = gameplay
        end

        def call
          validate!
          persist!

          @gameplay
        end

        private

        def validate!
          Validate.call(@gameplay)
        end

        def persist!
          @gameplay.save
        end
      end
    end
  end
end
