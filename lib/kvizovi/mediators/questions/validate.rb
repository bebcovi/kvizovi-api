require "kvizovi/utils"

module Kvizovi
  module Mediators
    class Questions
      class Validate
        def self.call(question)
          new(question).call
        end

        def initialize(question)
          @question = question
        end

        def call
          validate!
        end

        private

        def validate!
          @question.validates_presence :type, message: "Tip pitanja ne smije biti prazan"
          @question.validates_presence :title, message: "Naslov pitanja ne smije biti prazan"
          @question.validates_presence :content, message: "Sadržaj pitanja ne smije biti prazan"
          @question.validates_presence :position, message: "Pozicija pitanja ne smije biti prazna"
          @question.validates_unique [:position, :quiz_id], message: "Postoje više pitanja s istim rednim brojem (#{@question.position})"

          Utils.valid!(@question)
        end
      end
    end
  end
end
