require "kvizovi/mediators/account/password"
require "kvizovi/mailer"

require "securerandom"

module Kvizovi
  module Mediators
    class Account
      class Registration
        class Create
          PERMITTED_FIELDS = [
            :name, :email, :password,
            :avatar, :remove_avatar, :remote_avatar_url,
          ]

          def self.call(user_class, attrs)
            user = user_class.new
            user.set_only(attrs, *PERMITTED_FIELDS)
            new(user).call
          end

          def initialize(user)
            @user = user
          end

          def call
            encrypt_password!
            assign_confirmation_token!
            assign_auth_token!
            persist!
            email_confirmation!

            @user
          end

          private

          def encrypt_password!
            Password.new(@user).encrypt!
          end

          def assign_confirmation_token!
            @user.confirmation_token = ::SecureRandom.hex
          end

          def assign_auth_token!
            @user.token = ::SecureRandom.hex
          end

          def persist!
            @user.save
          end

          def email_confirmation!
            Mailer.send(:registration_confirmation, @user)
          end
        end
      end
    end
  end
end
