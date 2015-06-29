require "kvizovi/mediators/account/password"
require "kvizovi/elasticsearch"

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
            check_old_password!(attrs)
            assign!(attrs)
            encrypt_password!
            persist!
            elastic!

            @user
          end

          private

          def check_old_password!(attrs)
            old_password = attrs.delete(:old_password)
            if attrs[:password] && !password_matches?(old_password)
              raise ArgumentError, "password doesn't match current"
            end
          end

          def encrypt_password!
            Password.new(@user).encrypt! if @user.password
          end

          def password_matches?(password)
            Password.new(@user).matches?(password)
          end

          def assign!(attrs)
            @user.set_only(attrs, *PERMITTED_FIELDS)
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
