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

    def type_for(name)
      model = model_for(name)
      model.send(:underscore, model.send(:demodulize, model.to_s))
    end

    FACTORIES = {
      janko: [:User, {
        name: "Junky",
        email: "janko.marohnic@gmail.com",
        password: "secret",
      }],
      matija: [:User, {
        name: "Silvenon",
        email: "matija.marohnic@gmail.com",
        password: "secret",
      }],
      dori: [:User, {
        name: "Dorota",
        email: "dorota.tomaszova@gmail.com",
        password: "secret",
      }],
      quiz: [:Quiz, {
        name: "Game of Thrones",
        category: "movies",
        active: true,
      }],
      question: [:Question, {
        kind: "choice",
        title: "Who won the battle in Blackwater Bay?",
        content: {choices: ["Stannis Baratheon", "Tywin Lannister"], answer: "Tywin Lannister"},
        position: 1,
      }],
      boolean_question: [:Question, {
        kind: "boolean",
        title: "Stannis Baratheon won the battle in Blackwater Bay.",
        content: {answer: false},
        position: 1,
      }],
      choice_question: [:Question, {
        kind: "choice",
        title: "Who won the battle in Blackwater Bay?",
        content: {choices: ["Stannis Baratheon", "Tywin Lannister"], answer: "Tywin Lannister"},
        position: 1,
      }],
      association_question: [:Question, {
        kind: "association",
        title: "Connect characters with families:",
        content: {associations: {"Lannister" => "Cercei", "Stark" => "Robb"}},
        position: 1,
      }],
      text_question: [:Question, {
        kind: "text",
        title: "What's the name of King Baratheon's bastard son?",
        content: {answer: "Gendry"},
        position: 1,
      }],
      gameplay: [:Gameplay, {
        quiz_snapshot: {foo: "bar"},
        answers: {foo: "bar"},
        started_at: Time.now,
        finished_at: Time.now,
      }],
    }
  end
end
