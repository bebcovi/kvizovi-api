require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class QuestionMapper < BaseMapper
      attributes :id, :kind, :title, :content, :image, :hint, :position,
        :created_at, :updated_at

      has_one :quiz
    end
  end
end
