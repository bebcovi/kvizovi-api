require "kvizovi/mailer"

module Kvizovi
  class App
    route "contact" do |r|
      r.post true do
        Mailer.send(:contact, email_attributes); ""
      end
    end

    def email_attributes
      resource(:email)
    end
  end
end
