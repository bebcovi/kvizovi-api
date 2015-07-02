require "unit"
require "kvizovi/mediators/questions"

Questions = Kvizovi::Mediators::Questions

class QuestionsTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @quiz = create(:quiz)
    @questions = Questions.new(@quiz)
  end

  def test_all
    question = @questions.create(attributes_for(:question))

    assert_equal [question], @questions.all.to_a
  end

  def test_find
    question = @questions.create(attributes_for(:question))
    assert_equal question, @questions.find(question.id)

    assert_raises(Kvizovi::Error::ResourceNotFound) { @questions.find(-1) }
  end

  def test_create
    question = @questions.create(attributes_for(:question))

    assert question.exists?
  end

  def test_update
    question = @questions.create(attributes_for(:question))

    question = @questions.update(question.id, attributes_for(:question, title: "Changed title"))

    assert_equal "Changed title", question.title
    refute question.modified?
  end

  def test_destroy
    question = @questions.create(attributes_for(:question))

    @questions.destroy(question.id)

    refute question.exists?
  end

  def test_elasticsearch_indexing
    elastic do
      question = @questions.create(attributes_for(:question))
      results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
      refute_empty results.fetch(0)["questions"]

      @questions.update(question.id, {title: "Changed title"})
      results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
      assert_equal "Changed title", results.fetch(0)["questions"][0]["title"]

      @questions.destroy(question.id)
      results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
      assert_empty results.fetch(0)["questions"]
    end
  end

  def test_validation
    Questions.validate(build(:question))

    invalid { Questions.validate(build(:question, kind: nil)) }
    invalid { Questions.validate(build(:question, title: nil)) }
    invalid { Questions.validate(build(:question, content: nil)) }
    invalid { Questions.validate(build(:question, position: nil)) }

    question = @questions.create(attributes_for(:question))
    invalid { Questions.validate(build(:question, position: question.position, quiz: question.quiz)) }
    Questions.validate(build(:question, position: question.position))
  end

  def test_create_and_update_call_validation
    invalid { @questions.create(attributes_for(:question, title: nil)) }
    question = @questions.create(attributes_for(:question))
    invalid { @questions.update(question.id, title: nil) }
  end

  def test_mass_assignment
    assert_raises(Kvizovi::Error::InvalidAttribute) { @questions.create(created_at: nil) }
    question = @questions.create(attributes_for(:question))
    assert_raises(Kvizovi::Error::InvalidAttribute) { @questions.update(question.id, created_at: nil) }
  end
end
