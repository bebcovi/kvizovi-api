require "kvizovi/models/base"
require "kvizovi/configuration/refile"
require "kvizovi/elasticsearch"

module Kvizovi
  module Models
    class Quiz < Base
      many_to_one :creator, class: User
      one_to_many :questions, order: :position
      one_to_many :gameplays

      subset(:active, active: true)

      nested_attributes :questions

      extend Refile::Sequel::Attachment
      attachment :image

      def before_destroy
        questions_dataset.destroy
        super
      end

      def after_save
        super
        ElasticsearchIndex[:quiz].index(self)
      end

      def after_destroy
        super
        ElasticsearchIndex[:quiz].delete(self)
      end
    end
  end
end
