require "simple_mailer"

if ENV["RACK_ENV"] == "production"
  raise "Email configuration not set"
else
  SimpleMailer.smtp_settings.update(
    address: "localhost",
    port:    1025,
  )
end
