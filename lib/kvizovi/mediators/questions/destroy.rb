require "kvizovi/elasticsearch"

module Kvizovi
  module Mediators
    class Questions
      class Destroy
        def self.call(question)
          new(question).call
        end

        def initialize(question)
          @question = question
        end

        def call
          delete!
          elastic!

          @question
        end

        private

        def delete!
          @question.destroy
        end

        def elastic!
          @question.quiz.questions(true) # reload questions cache
          ElasticsearchIndex[:quiz].index(@question.quiz)
        end
      end
    end
  end
end
