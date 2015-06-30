require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class UserMapper < BaseMapper
      attributes :id, :name, :avatar_url, :email, :token,
        :created_at, :updated_at

      has_many :quizzes
      has_many :gameplays
      has_one :creator, mapper: UserMapper
    end
  end
end
