require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class UserMapper < BaseMapper
      attributes :id, :name, :email, :token, :avatar_url,
        :created_at, :updated_at

      has_many :quizzes
      has_many :gameplays
      has_one :creator, mapper: UserMapper
      has_many :players, mapper: UserMapper
    end
  end
end
