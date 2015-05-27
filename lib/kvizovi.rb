require "kvizovi/app"

module Kvizovi
  def self.app
    App.freeze.app
  end
end
