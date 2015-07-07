require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class ErrorMapper < BaseMapper
      attributes :id, :status, :title, :meta

      def attributes
        list = super
        list = list.reject { |attr| attr.name == :meta } if object.meta.empty?
        list
      end
    end
  end
end
