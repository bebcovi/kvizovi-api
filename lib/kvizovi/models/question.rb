require "kvizovi/models/base"
require "kvizovi/configuration/refile"

module Kvizovi
  module Models
    class Question < Base
      many_to_one :quiz

      extend Refile::Sequel::Attachment
      attachment :image
    end
  end
end
