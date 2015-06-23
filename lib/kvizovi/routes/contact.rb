require "kvizovi/mailer"

module Kvizovi
  class App
    route "contact" do |r|
      r.post true do
        Mailer.send(:contact, resource(:email)); ""
      end
    end
  end
end
