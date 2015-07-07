require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class QuizMapper < BaseMapper
      attributes :id, :name, :category, :questions_count, :image,
                 :created_at, :updated_at

      def image
        {
          small:  attachment_url(:image, 300, 300),
          medium: attachment_url(:image, 500, 500),
          large:  attachment_url(:image, 800, 800),
        }
      end

      has_one  :creator, mapper: UserMapper
      has_many :questions
      has_many :gameplays
    end
  end
end
