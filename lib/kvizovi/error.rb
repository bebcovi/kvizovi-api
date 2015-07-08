module Kvizovi
  class Error < ArgumentError
    def initialize(id)
      case id
      when Symbol
        @id = id
        super translations.fetch(id)
      when String
        super id
      end
    end

    attr_reader :id

    alias title message

    def status
      400
    end

    def meta
      {}
    end

    private

    def translations
      {}
    end

    class MissingParam < Error
      def initialize(key)
        @id = "param_missing"
        super "Missing param \"#{key}\""
      end
    end

    class Unauthorized < Error
      def status
        401
      end

      private

      def translations
        {
          authorization_missing:        "No authorization credentials given",
          token_missing:                "No authorization token given",
          token_invalid:                "No user with that token",
          credentials_invalid:          "Netočan email ili lozinka",
          confirmation_token_invalid:   "Confirmation token doesn't exist",
          password_reset_token_invalid: "Password reset token doesn't exist",
          email_invalid:                "Ne postoji korisnik s tom email adresom",
          account_expired:              "Trebate potvrditi korisnički račun preko dobivenog emaila",
        }
      end
    end

    class ResourceNotFound < Error
      def initialize(*)
        @id = "resource_not_found"
        super "Resource not found"
      end

      def status
        404
      end
    end

    class PageNotFound < Error
      def initialize(path)
        @id = "page_not_found"
        super "Route wasn't found: #{path}"
      end

      def status
        404
      end
    end

    class ValidationFailed < Error
      def initialize(errors)
        @errors = errors
        @id = "validation_failed"
        super "Resource validation has failed"
      end

      def meta
        {errors: @errors}
      end
    end

    class InvalidAttribute < Error
      def initialize(message)
        @id = "invalid_attribute"
        super message
      end
    end
  end
end
