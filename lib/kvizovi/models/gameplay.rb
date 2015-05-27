require "kvizovi/models/base"

module Kvizovi
  module Models
    class Gameplay < Base
      many_to_one :quiz
      pg_array_to_many :players, class: User
    end
  end
end
