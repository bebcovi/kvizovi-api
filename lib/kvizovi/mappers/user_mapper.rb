require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class UserMapper < BaseMapper
      attributes :id, :nickname, :avatar_url, :email, :token,
        :created_at, :updated_at

      has_many :quizzes
      has_many :gameplays
    end
  end
end
