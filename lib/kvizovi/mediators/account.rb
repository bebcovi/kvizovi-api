require "kvizovi/mediators/account/authenticator"
require "kvizovi/mediators/account/registration"
require "kvizovi/mediators/account/password"

require "kvizovi/models"
require "kvizovi/error"

module Kvizovi
  module Mediators
    class Account
      def self.register!(attributes)
        Registration.create(Models::User, attributes)
      end

      def self.authenticate(type = :credentials, object)
        Authenticator.authenticate(Models::User, type, object)
      end

      def self.confirm!(token)
        user = authenticate(:confirmation_token, token)
        new(user).confirm!
        user
      end

      def self.reset_password!(email)
        user = authenticate(:email, email)
        new(user).reset_password!
        user
      end

      def self.set_password!(token, attributes)
        user = authenticate(:password_reset_token, token)
        new(user).set_password!(attributes)
        user
      end

      def initialize(user)
        @user = user
      end

      def update!(attributes)
        registration.update!(attributes)
      end

      def confirm!
        registration.confirm!
      end

      def reset_password!
        password.reset!
      end

      def set_password!(attributes)
        password.set!(attributes)
      end

      def destroy!
        registration.destroy!
      end

      private

      def registration
        Registration.new(@user)
      end

      def password
        Password.new(@user)
      end
    end
  end
end
