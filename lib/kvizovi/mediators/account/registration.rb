require "kvizovi/mediators/account/registration/create"
require "kvizovi/mediators/account/registration/confirm"
require "kvizovi/mediators/account/registration/update"
require "kvizovi/mediators/account/registration/destroy"

require "as-duration"

module Kvizovi
  module Mediators
    class Account
      class Registration
        attr_reader :user

        def self.create(user_class, attrs)
          Create.call(user_class, attrs)
        end

        def initialize(user)
          @user = user
        end

        def confirm!
          Confirm.call(user)
        end

        def update!(attrs)
          Update.call(user, attrs)
        end

        def destroy!
          Destroy.call(user)
        end

        def confirmed?
          !!@user.confirmed_at
        end

        def expired?
          !confirmed? && Time.now > 3.days.since(@user.created_at)
        end
      end
    end
  end
end
