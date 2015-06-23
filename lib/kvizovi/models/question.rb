require "kvizovi/models/base"
require "kvizovi/configuration/refile"
require "kvizovi/elasticsearch"

module Kvizovi
  module Models
    class Question < Base
      many_to_one :quiz

      extend Refile::Sequel::Attachment
      attachment :image

      def after_save
        super
        ElasticsearchIndex[:quiz].index(quiz)
      end

      def after_destroy
        super
        quiz.questions(true)
        ElasticsearchIndex[:quiz].index(quiz)
      end
    end
  end
end
