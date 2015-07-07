require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class UserMapper < BaseMapper
      attributes :id, :name, :email, :token, :avatar,
                 :created_at, :updated_at

      def avatar
        {
          small:  attachment_url(:avatar, 300, 300),
          medium: attachment_url(:avatar, 500, 500),
          large:  attachment_url(:avatar, 800, 800),
        }
      end

      has_many :quizzes
      has_many :gameplays
      has_one :creator, mapper: UserMapper
      has_many :players, mapper: UserMapper
    end
  end
end
