require "kvizovi/mediators/account"

module Kvizovi
  class App
    route "account" do |r|
      r.is do
        r.get do
          Mediators::Account.authenticate(authorization.value)
        end

        r.post do
          Mediators::Account.register!(user_attributes)
        end

        r.patch do
          Mediators::Account.new(current_user).update!(user_attributes)
        end

        r.delete do
          Mediators::Account.new(current_user).destroy!
        end
      end

      r.patch "confirm" do
        Mediators::Account.confirm!(required(:token))
      end

      r.post "password" do
        Mediators::Account.reset_password!(required(:email))
      end

      r.patch "password" do
        Mediators::Account.set_password!(required(:token), user_attributes)
      end

      r.get "players" do
        Mediators::Account.new(current_user).players
      end

      r.get "typeahead" do
        Mediators::Account.typeahead(params)
      end
    end

    def user_attributes
      resource(:user).tap do |attributes|
        uploaded_file(attributes, :avatar)
      end
    end
  end
end
