require "kvizovi/mediators/quizzes"
require "kvizovi/mediators/questions"

module Kvizovi
  class App
    plugin :header_matchers

    route "quizzes" do |r|
      auth = {header: "HTTP_AUTHORIZATION"}

      r.is do
        r.get auth do
          Mediators::Quizzes.new(current_user).all
        end

        r.get do
          Mediators::Quizzes.search(params)
        end

        r.post auth do
          Mediators::Quizzes.new(current_user).create(quiz_attributes)
        end
      end

      r.is ":id" do |quiz_id|
        r.get auth do
          Mediators::Quizzes.new(current_user).find(quiz_id)
        end

        r.get do
          Mediators::Quizzes.find(quiz_id)
        end

        r.patch auth do
          Mediators::Quizzes.new(current_user).update(quiz_id, quiz_attributes)
        end

        r.delete auth do
          Mediators::Quizzes.new(current_user).destroy(quiz_id)
        end
      end

      r.on ":id" do |quiz_id|
        quiz = Mediators::Quizzes.new(current_user).find(quiz_id)

        r.on "questions" do
          r.is do
            r.get do
              Mediators::Questions.new(quiz).all
            end

            r.post do
              Mediators::Questions.new(quiz).create(question_attributes)
            end
          end

          r.is ":id" do |question_id|
            r.get do
              Mediators::Questions.new(quiz).find(question_id)
            end

            r.patch do
              Mediators::Questions.new(quiz).update(question_id, question_attributes)
            end

            r.delete do
              Mediators::Questions.new(quiz).destroy(question_id)
            end
          end
        end
      end
    end

    def quiz_attributes
      resource(:quiz).tap do |attributes|
        uploaded_file(attributes, :image)
        Array(attributes[:question_attributes]).each { |hash| uploaded_file(hash, :image) }
      end
    end

    def question_attributes
      resource(:question).tap do |attributes|
        uploaded_file(attributes, :image)
      end
    end
  end
end
