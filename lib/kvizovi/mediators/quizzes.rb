require "kvizovi/finders/quiz_finder"
require "kvizovi/mediators/quizzes/create"
require "kvizovi/mediators/quizzes/update"
require "kvizovi/mediators/quizzes/destroy"
require "kvizovi/mediators/quizzes/validate"

module Kvizovi
  module Mediators
    class Quizzes
      PERMITTED_FIELDS = [
        :name, :category, :shuffle, :questions_attributes,
        :image, :remove_image, :remote_image_url,
      ]

      def self.search(**options)
        Finders::QuizFinder.search(**options)
      end

      def self.validate(quiz)
        Validate.call(quiz)
      end

      def self.find(id)
        Finders::QuizFinder.find(id)
      end

      def initialize(user)
        @user = user
      end

      def all
        Finders::QuizFinder.new(@user.quizzes_dataset).all
      end

      def find(id)
        Finders::QuizFinder.new(all).find(id)
      end

      def create(attrs)
        Create.call(**attrs, creator: @user)
      end

      def update(id, attrs)
        Update.call(find(id), attrs)
      end

      def destroy(id)
        Destroy.call(find(id))
      end

      def destroy_all
        @user.quizzes.each { |quiz| Destroy.call(quiz) }
      end
    end
  end
end
