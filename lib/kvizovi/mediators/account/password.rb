require "kvizovi/mailer"
require "bcrypt"
require "securerandom"

module Kvizovi
  module Mediators
    class Account
      class Password
        def initialize(user)
          @user = user
        end

        def reset!
          assign_reset_token!
          @user.save
          email_reset_instructions!
        end

        def set!(attributes)
          @user.set_only(attributes, :password)
          encrypt!
          @user.password_reset_token = nil
          @user.save
        end

        def matches?(password)
          ::BCrypt::Password.new(@user.encrypted_password) == password
        end

        def encrypt!
          @user.encrypted_password = ::BCrypt::Password.create(@user.password)
        end

        private

        def assign_reset_token!
          @user.password_reset_token = ::SecureRandom.hex
        end

        def email_reset_instructions!
          Mailer.send(:password_reset_instructions, @user)
        end
      end
    end
  end
end
