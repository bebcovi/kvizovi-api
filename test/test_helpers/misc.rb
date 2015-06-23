module TestHelpers
  module Misc
    def sent_emails
      SimpleMailer.emails_sent.map do |message, from, to|
        {message: message, from: from, to: to}
      end
    end

    def email_link
      require "uri"
      last_message = sent_emails.last[:message]
      url = last_message[%r{http://\S+$}]
      URI(url).request_uri
    end

    def image
      Rack::Test::UploadedFile.new("test/fixtures/image.jpg")
    end

    def log
      require "logger"
      DB.logger = Logger.new(STDOUT)
      yield
      DB.logger = Logger.new(nil)
    end

    def profile(&block)
      require "ruby-prof"
      result = RubyProf.profile(&block)
      printer = RubyProf::CallStackPrinter.new(result)
      File.open("profile.html", "w") { |file| printer.print(file) }
    end
  end
end
