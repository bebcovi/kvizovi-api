require "kvizovi/configuration/sequel"
require "kvizovi/mediators/quizzes"
require "kvizovi/mediators/gameplays"

module Kvizovi
  module Mediators
    class Account
      class Registration
        class Destroy
          def self.call(user)
            new(user).call
          end

          def initialize(user)
            @user = user
          end

          def call
            delete!

            @user
          end

          private

          def delete!
            DB.transaction do
              Quizzes.new(@user).destroy_all
              Gameplays.new(@user).destroy_all
              @user.destroy
            end
          end
        end
      end
    end
  end
end
