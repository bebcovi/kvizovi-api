require "json"
require "kvizovi/error"

module Kvizovi
  module Utils
    module_function

    def dump_json(data, env)
      if ENV["RACK_ENV"] == "production"
        JSON.generate(data)
      else
        JSON.pretty_generate(data)
      end
    end

    def resource(params, name)
      data = require_param(params, :data)
      attributes = data.fetch(:attributes)

      links = data.fetch(:links, {})
      links.inject({}) do |hash, (name, info)|
        attributes[:associations] ||= {}
        if Hash === info[:linkage]
          attributes[:associations].update(name => info[:linkage][:id])
        else
          attributes[:associations].update(name => info[:linkage].map { |rel| rel[:id] })
        end
      end

      attributes
    end

    def require_param(params, name)
      params.fetch(name)
    rescue KeyError
      raise Kvizovi::Error::MissingParam, name
    end

    def valid!(object)
      if object.errors.any?
        raise Kvizovi::Error::ValidationFailed, object.errors
      end
    end

    def mass_assign!(object, attrs, permitted_fields)
      object.set_only(attrs, *permitted_fields)
    rescue Sequel::MassAssignmentRestriction => error
      raise Kvizovi::Error::InvalidAttribute, error.message
    end
  end
end
