require "kvizovi/mediators/account/registration/validate"
require "kvizovi/mediators/account/password"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Account
      class Registration
        class Update
          PERMITTED_FIELDS = [
            :name, :email, :password, :old_password,
            :avatar, :remove_avatar, :remote_avatar_url,
          ]

          def self.call(user, attrs)
            new(user).call(attrs)
          end

          def initialize(user)
            @user = user
          end

          def call(attrs)
            assign!(attrs)
            validate!
            encrypt_password!
            persist!
            elastic!

            @user
          end

          private

          def validate!
            Validate.call(@user)
          end

          def encrypt_password!
            Password.new(@user).encrypt! if @user.password
          end

          def assign!(attrs)
            @user.creator_id = (attrs.delete(:associations) || {})[:creator]
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
