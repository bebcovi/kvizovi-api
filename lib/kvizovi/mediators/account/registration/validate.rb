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
            @user.validates_presence :name, message: "Ime mora biti unešeno"
            @user.validates_presence :email, message: "Email adresa mora biti unešena"
            @user.validates_unique :name, message: "Već postoji korisnik s imenom #{@user.name.inspect}"
            @user.validates_unique :email, message: "Već postoji korisnik s email adresom #{@user.email.inspect}"
            if @user.new?
              @user.validates_presence :password, message: "Lozinka mora biti unešena"
            else
              if @user.password && !password_matches?(@user.old_password)
                @user.errors.add(:old_password, "Stara lozinka ne odgovara trenutnoj")
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
