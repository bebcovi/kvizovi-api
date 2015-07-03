module TestHelpers
  module Email
    def setup
      super
      if defined?(Sidekiq)
        require "sidekiq/testing"
        Sidekiq::Testing.inline!
      end
    end

    def teardown
      super
      SimpleMailer.emails_sent.clear if defined?(SimpleMailer)
    end

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
  end
end
