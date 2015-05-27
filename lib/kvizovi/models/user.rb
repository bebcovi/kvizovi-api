require "kvizovi/models/base"
require "kvizovi/configuration/refile"

module Kvizovi
  module Models
    class User < Base
      one_to_many :quizzes, key: :creator_id
      many_to_pg_array :gameplays, key: :player_ids

      extend Refile::Sequel::Attachment
      attachment :avatar

      attr_accessor :password

      def before_destroy
        quizzes_dataset.destroy
        gameplays_dataset.destroy
        super
      end
    end
  end
end
