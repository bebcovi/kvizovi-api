require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Gameplays
      class Validate
        def self.call(gameplay)
          new(gameplay).call
        end

        def initialize(gameplay)
          @gameplay = gameplay
        end

        def call
          validate!
        end

        private

        def validate!
          @gameplay.validates_presence :quiz_snapshot, message: "Snimka kviza ne smije biti prazna"
          @gameplay.validates_presence :answers, message: "Odgovori odigranog kviza ne smiju biti prazni"
          @gameplay.validates_presence :started_at, message: "Početak odigranog kviza ne smije biti prazno"
          @gameplay.validates_presence :finished_at, message: "Kraj odigranog kviza ne smije biti prazan"

          Utils.valid!(@gameplay)
        end
      end
    end
  end
end
