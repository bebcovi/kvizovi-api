require "kvizovi/models"
require "kvizovi/error"

module Kvizovi
  module Finders
    class BaseFinder
      def self.method_missing(name, *args, &block)
        new(model.dataset).send(name, *args, &block)
      end

      def self.model(klass = nil)
        if klass
          @model = klass
        else
          @model
        end
      end

      def initialize(dataset)
        raise ArgumentError if not dataset.is_a?(Sequel::Dataset)
        @dataset = dataset
      end

      attr_reader :dataset

      def find_by_id(id)
        dataset.first(id: id) || not_found!(id)
      end

      def paginate(page)
        page_number = Integer(page[:number] || 1)
        page_size   = Integer(page[:size])

        dataset.paginate(page_number, page_size)
      end

      private

      def new(dataset)
        self.class.new(dataset)
      end

      def not_found!(id)
        model_name = self.class.model.name.split("::").first
        raise Kvizovi::Error::NotFound, "#{model_name} with id #{id} not found"
      end
    end
  end
end
