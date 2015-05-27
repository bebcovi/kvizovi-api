require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class QuizMapper < BaseMapper
      attributes :id, :name, :category, :image, :questions_count,
        :created_at, :updated_at

      has_one  :creator, mapper: UserMapper
      has_many :questions
      has_many :gameplays
    end
  end
end
