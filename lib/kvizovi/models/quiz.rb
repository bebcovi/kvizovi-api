require "kvizovi/models/base"
require "kvizovi/configuration/refile"

module Kvizovi
  module Models
    class Quiz < Base
      many_to_one :creator, class: User
      one_to_many :questions, order: :position
      one_to_many :gameplays

      nested_attributes :questions

      extend Refile::Sequel::Attachment
      attachment :image
    end
  end
end
