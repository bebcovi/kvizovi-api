require "json"
require "inflection"
require "delegate"

module TestHelpers
  module JsonApi
    class Response < DelegateClass(Rack::Response)
      def parsed_body
        JSON.parse(body)
      end

      def data
        parsed_body.fetch("data")
      end

      def included
        parsed_body.fetch("included")
      end

      def errors
        parsed_body.fetch("errors")
      end

      def error
        errors.fetch(0)
      rescue IndexError
        raise "no error in #{errors.to_json}"
      end

      def resource(name)
        resources(Inflection.plural(name)).fetch(0)
      rescue IndexError
        raise "no resource \"#{name}\" in #{body}"
      end

      def resources(type)
        extract_resources(data)
          .select { |resource| resource["type"] == type }
      end

      private

      def extract_resources(collection)
        Array(collection).map do |hash|
          item = {}
          item.update(hash.fetch("attributes"))
          item.update("id" => hash.fetch("id"), "type" => hash.fetch("type"))
          (hash["relationships"] || {}).each do |association_name, association_data|
            association_identifiers = association_data.fetch("data")
            associated_resources =
              case association_identifiers
              when Hash then included_resource(association_identifiers)
              when Array then included_resources(association_identifiers)
              end
            item.update(association_name => associated_resources)
          end
          item
        end
      end

      def included_resources(identifiers)
        extract_resources(included)
          .select { |r| identifiers.include?({"type" => r["type"], "id" => r["id"]}) }
      end

      def included_resource(identifier)
        included_resources([identifier]).fetch(0)
      rescue IndexError
        raise "no resource \"#{identifier}\" in #{included}"
      end

      def Array(object)
        if Hash === object
          [object]
        else
          super
        end
      end
    end

    def json_attributes_for(name, **options)
      {
        type: Inflection.plural(type_for(name)),
        attributes: attributes_for(name, **options),
      }
    end

    def responses
      @responses.map { |resp| Response.new(resp) }
    end

    def response
      Response.new(last_response)
    end
  end
end
