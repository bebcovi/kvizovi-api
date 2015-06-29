require "kvizovi/elasticsearch"

module Kvizovi
  module Mediators
    class Questions
      class Update
        def self.call(question, attrs)
          new(question).call(attrs)
        end

        def initialize(question)
          @question = question
        end

        def call(attrs)
          assign!(attrs)
          persist!
          elastic!

          @question
        end

        private

        def assign!(attrs)
          @question.set(attrs)
        end

        def persist!
          @question.save
        end

        def elastic!
          ElasticsearchIndex[:quiz].index(@question.quiz)
        end
      end
    end
  end
end
