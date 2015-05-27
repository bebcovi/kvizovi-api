module TestHelpers
  module Factory
    def create(name, additional_attributes = {})
      model_for(name).create(attributes_for(name, additional_attributes))
    end

    def build(name, additional_attributes = {})
      model_for(name).new(attributes_for(name, additional_attributes))
    end

    def attributes_for(name, additional_attributes = {})
      attributes = FACTORIES.fetch(name)[1]
      attributes.merge(additional_attributes)
    end

    def model_for(name)
      model_name = FACTORIES.fetch(name)[0]
      Kvizovi::Models.const_get(model_name)
    end

    FACTORIES = {
      janko: [:User, {
        nickname: "Junky",
        email: "janko.marohnic@gmail.com",
        password: "secret",
      }],
      matija: [:User, {
        nickname: "Silvenon",
        email: "matija.marohnic@gmail.com",
        password: "secret",
      }],
      quiz: [:Quiz, {
        name: "Game of Thrones",
        category: "movies",
      }],
      question: [:Question, {
        type: "choice",
        title: "Who won the battle in Blackwater Bay?",
        content: {choices: ["Stannis Baratheon", "Tywin Lannister"], answer: "Tywin Lannister"},
      }],
      boolean_question: [:Question, {
        type: "boolean",
        title: "Stannis Baratheon won the battle in Blackwater Bay.",
        content: {answer: false},
      }],
      choice_question: [:Question, {
        type: "choice",
        title: "Who won the battle in Blackwater Bay?",
        content: {choices: ["Stannis Baratheon", "Tywin Lannister"], answer: "Tywin Lannister"},
      }],
      association_question: [:Question, {
        type: "association",
        title: "Connect characters with families:",
        content: {associations: {"Lannister" => "Cercei", "Stark" => "Robb"}},
      }],
      text_question: [:Question, {
        type: "text",
        title: "What's the name of King Baratheon's bastard son?",
        content: {answer: "Gendry"},
      }],
      gameplay: [:Gameplay, {
        quiz_snapshot: {},
        answers: {},
        started_at: Time.now,
        finished_at: Time.now,
      }],
    }
  end
end
