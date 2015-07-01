require "simple_mailer"
require "unindent"

module Kvizovi
  class Mailer
    def self.send(*args)
      new.send(*args)
    end

    def password_reset_instructions(user)
      send_email(
        from:    "Kvizovi <janko.marohnic@gmail.com>",
        to:      user.email,
        subject: "[Kvizovi] Upute za resetiranje lozinke",
        body:    <<-BODY.unindent,
          Da biste promijenili lozinku, posjetite ovaj link:

          http://kvizovi.org/account/password?token=#{user.password_reset_token}

          Ukoliko niste zatražili promjenu lozinke, ignorirajte ovaj email. Vaša
          lozinka se neće promijeniti dok ne posjetite gornji link.

          Vaši Kvizovi
        BODY
      )
    end

    def registration_confirmation(user)
      send_email(
        from:    "Kvizovi <janko.marohnic@gmail.com>",
        to:      user.email,
        subject: "[Kvizovi] Dovršite registraciju",
        body:    <<-BODY.unindent,
          Da dovršite registraciju, posjetite ovaj link:

          http://kvizovi.org/account/confirm?token=#{user.confirmation_token}

          Vaši Kvizovi
        BODY
      )
    end

    def contact(info)
      send_email(
        from:    info.fetch(:from),
        to:      "janko.marohnic@gmail.com",
        cc:      "matija.marohnic@gmail.com",
        subject: "[Kvizovi] #{info.fetch(:body)[0..20]}...",
        body:    info.fetch(:body),
      )
    end

    private

    def send_email(from:, to:, cc: nil, subject:, body:)
      SimpleMailer.send_email(from, to, subject, body, cc: cc)
    end
  end
end
