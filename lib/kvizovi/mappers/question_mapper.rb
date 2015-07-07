require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class QuestionMapper < BaseMapper
      attributes :id, :kind, :title, :content, :hint, :position, :image,
                 :created_at, :updated_at

      def image
        {
          small:  attachment_url(:image, 300, 300),
          medium: attachment_url(:image, 500, 500),
          large:  attachment_url(:image, 800, 800),
        }
      end

      has_one :quiz
    end
  end
end
