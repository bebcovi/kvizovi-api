require "uri"
require "logger"

module TestHelpers
  module Misc
    def sent_emails
      SimpleMailer.emails_sent.map do |message, from, to|
        {message: message, from: from, to: to}
      end
    end

    def email_link
      last_message = sent_emails.last[:message]
      url = last_message[%r{http://\S+$}]
      URI(url).request_uri
    end

    def image
      Rack::Test::UploadedFile.new("test/fixtures/image.jpg")
    end

    def log
      DB.logger = Logger.new(STDOUT)
      yield
      DB.logger = Logger.new(nil)
    end
  end
end
