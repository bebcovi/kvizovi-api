require "yaks"
require "yaks/behaviour/optional_includes"
require "kvizovi/configuration/refile"

module Kvizovi
  module Mappers
    class BaseMapper < Yaks::Mapper
      include Yaks::Behaviour::OptionalIncludes

      private

      def attachment_url(name, width, height)
        Refile.attachment_url(object, name, :fit, width, height)
      end
    end
  end
end
