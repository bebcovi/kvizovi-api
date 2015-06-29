module TestHelpers
  module Elastic
    def self.included(base)
      base.extend ClassMethods
    end

    def before_all
      super
      if defined?(Kvizovi::ElasticsearchIndex)
        Kvizovi::ElasticsearchIndex.noop = true
        Kvizovi::ElasticsearchIndex.refresh = true
      end
    end

    def elastic
      Kvizovi::ElasticsearchIndex.noop = false
      Kvizovi::ElasticsearchIndex.create!
      yield
      Kvizovi::ElasticsearchIndex.delete!
      Kvizovi::ElasticsearchIndex.noop = true
    end

    module ClassMethods
      def elastic!
        define_method(:before_all) do
          super()
          Kvizovi::ElasticsearchIndex.noop = false
          Kvizovi::ElasticsearchIndex.create!
        end

        define_method(:after_all) do
          super()
          Kvizovi::ElasticsearchIndex.delete!
          Kvizovi::ElasticsearchIndex.noop = true
        end
      end
    end
  end
end
