require "unit"
require "kvizovi/mediators/questions"

Questions = Kvizovi::Mediators::Questions

class QuestionsTest < UnitTest
  def setup
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

    assert_raises(Kvizovi::Error::NotFound) { @questions.find(-1) }
  end

  def test_create
    question = @questions.create(attributes_for(:question))

    assert question.exists?
  end

  def test_update
    question = @questions.create(attributes_for(:question))

    question = @questions.update(question.id, title: "Changed title")

    assert_equal "Changed title", question.title
    refute question.modified?
  end

  def test_destroy
    question = @questions.create(attributes_for(:question))

    @questions.destroy(question.id)

    refute question.exists?
  end
end
