require "kvizovi/utils"
require "kvizovi/mediators/account/password"

module Kvizovi
  module Mediators
    class Account
      class Registration
        class Validate
          def self.call(user)
            new(user).call
          end

          def initialize(user)
            @user = user
          end

          def call
            validate!
          end

          private

          def validate!
            @user.validates_presence [:name, :email]
            @user.validates_unique :name, :email
            if @user.new?
              @user.validates_presence :password
            else
              if @user.password && !password_matches?(@user.old_password)
                @user.errors.add(:old_password, "doesn't match the current one")
              end
            end

            Utils.valid!(@user)
          end

          def password_matches?(password)
            Password.new(@user).matches?(password)
          end
        end
      end
    end
  end
end
