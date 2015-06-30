require "kvizovi/models/base"
require "kvizovi/configuration/refile"

module Kvizovi
  module Models
    class User < Base
      one_to_many :quizzes, key: :creator_id
      many_to_pg_array :gameplays, key: :player_ids
      many_to_one :creator, class: User
      one_to_many :players, class: User, key: :creator_id

      extend Refile::Sequel::Attachment
      attachment :avatar

      attr_accessor :password
    end
  end
end
