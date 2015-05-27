require "kvizovi/mappers/base_mapper"

module Kvizovi
  module Mappers
    class ErrorMapper < BaseMapper
      attributes :id, :status, :title
    end
  end
end
