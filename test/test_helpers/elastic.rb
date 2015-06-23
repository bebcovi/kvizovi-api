module TestHelpers
  module Elastic
    def before_all
      super
      if defined?(Kvizovi::ElasticsearchIndex)
        Kvizovi::ElasticsearchIndex.create!
        Kvizovi::ElasticsearchIndex.refresh = true
      end
    end

    def setup
      super
      if defined?(Kvizovi::ElasticsearchIndex)
        Kvizovi::ElasticsearchIndex.noop = true
      end
    end

    def teardown
      super
      if defined?(Kvizovi::ElasticsearchIndex)
        Kvizovi::ElasticsearchIndex.clear
        Kvizovi::ElasticsearchIndex.noop = false
      end
    end

    def after_all
      super
      if defined?(Kvizovi::ElasticsearchIndex)
        Kvizovi::ElasticsearchIndex.delete!
      end
    end
  end
end
