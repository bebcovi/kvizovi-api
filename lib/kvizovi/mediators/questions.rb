require "kvizovi/finders/question_finder"
require "kvizovi/mediators/questions/create"
require "kvizovi/mediators/questions/update"
require "kvizovi/mediators/questions/destroy"
require "kvizovi/mediators/questions/validate"

module Kvizovi
  module Mediators
    class Questions
      PERMITTED_FIELDS = [:type, :title, :content, :image, :hint, :position]

      def self.validate(question)
        Validate.call(question)
      end

      def initialize(quiz)
        @quiz = quiz
      end

      def all
        Finders::QuestionFinder.new(@quiz.questions_dataset).all
      end

      def find(id)
        Finders::QuestionFinder.new(all).find(id)
      end

      def create(attrs)
        Create.call(**attrs, quiz: @quiz)
      end

      def update(id, attrs)
        Update.call(find(id), attrs)
      end

      def destroy(id)
        Destroy.call(find(id))
      end

      def destroy_all
        @quiz.questions_dataset.delete
      end
    end
  end
end
