require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class GameplayMapper < BaseMapper
      attributes :id, :quiz_snapshot, :players_count, :answers,
        :started_at, :finished_at

      has_many :players, mapper: UserMapper
      has_one  :quiz

      def players_count
        object.player_ids.count
      end
    end
  end
end
