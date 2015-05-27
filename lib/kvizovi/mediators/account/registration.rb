require "kvizovi/mediators/account/password"
require "kvizovi/mailer"

require "as-duration"
require "securerandom"

module Kvizovi
  module Mediators
    class Account
      class Registration
        attr_reader :user

        VALID_FIELDS = [
          :nickname, :email, :password,
          :avatar, :remove_avatar, :remote_avatar_url,
        ]

        def self.create(user_class, attributes)
          user = user_class.new
          user.set_only(attributes, *VALID_FIELDS)
          new(user).save!
        end

        def initialize(user)
          @user = user
        end

        def save!
          encrypt_password!
          assign_confirmation_token!
          assign_auth_token!
          @user.save
          email_confirmation!

          @user
        end

        def confirm!
          @user.update(confirmed_at: Time.now, confirmation_token: nil)
        end

        def confirmed?
          !!@user.confirmed_at
        end

        def expired?
          !confirmed? && Time.now > 3.days.since(@user.created_at)
        end

        def update!(attributes)
          old_password = attributes.delete(:old_password)
          @user.set_only(attributes, *VALID_FIELDS)
          if @user.password
            raise ArgumentError, "password doesn't match current" if !password_matches?(old_password)
            encrypt_password!
          end
          @user.save

          @user
        end

        def destroy!
          @user.destroy
        end

        private

        def encrypt_password!
          Password.new(@user).encrypt!
        end

        def password_matches?(password)
          Password.new(@user).matches?(password)
        end

        def assign_confirmation_token!
          @user.confirmation_token = ::SecureRandom.hex
        end

        def assign_auth_token!
          @user.token = ::SecureRandom.hex
        end

        def email_confirmation!
          Mailer.send(:registration_confirmation, @user)
        end
      end
    end
  end
end
