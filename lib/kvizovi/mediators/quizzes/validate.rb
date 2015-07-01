require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Quizzes
      class Validate
        def self.call(quiz)
          new(quiz).call
        end

        def initialize(quiz)
          @quiz = quiz
        end

        def call
          validate_quiz!
          validate_questions!
        end

        private

        def validate_quiz!
          @quiz.validates_presence :name, message: "Ime kviza ne može biti prazno"
          @quiz.validates_presence :category, message: "Kategorija kviza ne može biti prazna"
          @quiz.validates_unique [:name, :creator_id], message: "Već imate kviz s imenom #{@quiz.name.inspect}"

          Utils.valid!(@quiz)
        end

        def validate_questions!
          @quiz.questions.each { |question| Questions.validate(question) }
        end
      end
    end
  end
end
