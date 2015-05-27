require "kvizovi/mediators/account/password"

module Kvizovi
  module Mediators
    class Account
      class Authenticator
        def self.authenticate(user_class, type, object)
          user = new(user_class).send(:authenticate, type, object)
          raise Kvizovi::Error::Unauthorized, :"#{type}_invalid" if user.nil?
          user
        end

        def initialize(user_class)
          @user_class = user_class
        end

        def authenticate(type, object)
          user = send("authenticate_from_#{type}", object)
          raise Kvizovi::Error::Unauthorized, :account_expired if user && registration_expired?(user)
          user
        end

        protected

        def authenticate_from_email(email)
          @user_class.find(email: email)
        end

        def authenticate_from_credentials(credentials)
          if credentials.is_a?(Array)
            user = @user_class.find(email: credentials[0])
            user if user && password_matches?(user, credentials[1])
          else
            authenticate_from_token(credentials)
          end
        end

        def authenticate_from_token(token)
          @user_class.find(token: token)
        end

        def authenticate_from_confirmation_token(token)
          @user_class.find(confirmation_token: token)
        end

        def authenticate_from_password_reset_token(token)
          @user_class.find(password_reset_token: token)
        end

        private

        def password_matches?(user, password)
          Password.new(user).matches?(password)
        end

        def registration_expired?(user)
          Registration.new(user).expired?
        end
      end
    end
  end
end
