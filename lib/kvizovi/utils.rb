require "json"
require "inflection"
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
      raise Kvizovi::Error, "no resource of type #{name}" if data[:type] != Inflection.plural(name.to_s)
      attributes = data.fetch(:attributes)

      links = data.fetch(:relationships, {})
      links.inject({}) do |hash, (name, info)|
        attributes[:associations] ||= {}
        if Hash === info[:data]
          attributes[:associations].update(name => info[:data][:id])
        else
          attributes[:associations].update(name => info[:data].map { |rel| rel[:id] })
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
        errors = object.errors.flat_map { |column, messages| messages }
        raise Kvizovi::Error::ValidationFailed, errors
      end
    end

    def mass_assign!(object, attrs, permitted_fields)
      object.set_only(attrs, *permitted_fields)
    rescue Sequel::MassAssignmentRestriction => error
      raise Kvizovi::Error::InvalidAttribute, error.message
    end
  end
end
