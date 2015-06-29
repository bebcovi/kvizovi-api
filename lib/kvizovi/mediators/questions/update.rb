require "kvizovi/mediators/questions/validate"
require "kvizovi/elasticsearch"
require "kvizovi/utils"

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
          validate!
          persist!
          elastic!

          @question
        end

        private

        def assign!(attrs)
          Utils.mass_assign!(@question, attrs, PERMITTED_FIELDS)
        end

        def validate!
          Validate.call(@question)
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
