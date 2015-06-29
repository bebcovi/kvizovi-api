require "kvizovi/mediators/account/password"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Account
      class Registration
        class Update
          PERMITTED_FIELDS = [
            :name, :email, :password,
            :avatar, :remove_avatar, :remote_avatar_url,
          ]

          def self.call(user, attrs)
            new(user).call(attrs)
          end

          def initialize(user)
            @user = user
          end

          def call(attrs)
            old_password = attrs.delete(:old_password)
            assign!(attrs)
            validate!(old_password)
            encrypt_password!
            persist!
            elastic!

            @user
          end

          private

          def validate!(old_password)
            @user.validates_presence [:name, :email]
            @user.validates_unique :name, :email
            if @user.password && !password_matches?(old_password)
              @user.errors.add(:old_password, "password doesn't match current")
            end

            Utils.valid!(@user)
          end

          def encrypt_password!
            Password.new(@user).encrypt! if @user.password
          end

          def password_matches?(password)
            Password.new(@user).matches?(password)
          end

          def assign!(attrs)
            Utils.mass_assign!(@user, attrs, PERMITTED_FIELDS)
          end

          def persist!
            @user.save
          end

          def elastic!
            ElasticsearchIndex[:quiz].index(@user.quizzes)
          end
        end
      end
    end
  end
end
