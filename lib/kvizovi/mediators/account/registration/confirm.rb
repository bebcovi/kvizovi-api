module Kvizovi
  module Mediators
    class Account
      class Registration
        class Confirm
          def self.call(user)
            new(user).call
          end

          def initialize(user)
            @user = user
          end

          def call
            confirm!

            @user
          end

          private

          def confirm!
            @user.update(confirmed_at: Time.now, confirmation_token: nil)
          end
        end
      end
    end
  end
end
