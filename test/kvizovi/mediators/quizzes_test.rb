require "unit"
require "kvizovi/mediators/quizzes"

Quizzes = Kvizovi::Mediators::Quizzes

class QuizzesTest < UnitTest
  def setup
    super
    @user = create(:janko)
    @quizzes = Quizzes.new(@user)
  end

  def test_search_quiz_name
    quiz = @quizzes.create(attributes_for(:quiz, name: "Game of Thrones"))

    assert_equal [quiz], Quizzes.search(q: "game").to_a
  end

  def test_search_questions
    quiz = @quizzes.create(attributes_for(:quiz, questions_attributes: [
      attributes_for(:question, title: "Stannis Baratheon won Blackwater Bay"),
      attributes_for(:question, title: "Lannisters won Blackwater Bay"),
    ]))

    assert_equal [quiz], Quizzes.search(q: "blackwater").to_a
  end

  def test_search_by_category
    quiz = @quizzes.create(attributes_for(:quiz, category: "movies"))

    assert_equal [quiz], Quizzes.search(category: "movies").to_a
  end

  def test_search_pagination
    quiz1 = @quizzes.create(attributes_for(:quiz))
    quiz2 = @quizzes.create(attributes_for(:quiz))

    assert_equal [quiz1], Quizzes.search(page: {number: 1, size: 1}).to_a
    assert_equal [quiz2], Quizzes.search(page: {number: 2, size: 1}).to_a
  end

  def test_search_active
    quiz = @quizzes.create(attributes_for(:quiz, active: false))

    assert_equal [], Quizzes.search(q: "").to_a
  end

  def test_generic_finding
    quiz = @quizzes.create(attributes_for(:quiz))

    assert_equal quiz, Quizzes.find(quiz.id)
  end

  def test_finding_by_user
    quiz = @quizzes.create(attributes_for(:quiz))
    assert_equal quiz, @quizzes.find(quiz.id)

    quiz = create(:quiz, creator: create(:matija))
    assert_raises(Kvizovi::Error::NotFound) { @quizzes.find(quiz.id) }
  end

  def test_not_found
    assert_raises(Kvizovi::Error::NotFound) { Quizzes.find(-1) }
    assert_raises(Kvizovi::Error::NotFound) { @quizzes.find(-1) }
  end

  def test_create
    quiz = @quizzes.create(attributes_for(:quiz))

    refute quiz.new?
  end

  def test_updating_quiz
    quiz = @quizzes.create(attributes_for(:quiz))

    quiz = @quizzes.update(quiz.id, {name: "New name"})

    assert_equal "New name", quiz.name
    refute quiz.modified?
  end

  def test_updating_questions_touches_quiz
    quiz = @quizzes.create(attributes_for(:quiz))
    last_updated = quiz.updated_at

    quiz = @quizzes.update(quiz.id, {questions_attributes: [attributes_for(:question)]})
    assert quiz.updated_at > last_updated
  end

  def test_updating_scopes_to_user
    quiz = create(:quiz, creator: create(:matija))

    assert_raises(Kvizovi::Error::NotFound) { @quizzes.update(quiz.id, {}) }
  end

  def test_destroying_quiz
    quiz = @quizzes.create(attributes_for(:quiz))

    @quizzes.destroy(quiz.id)

    refute quiz.exists?
  end

  def test_destroying_associated_questions
    quiz = @quizzes.create(attributes_for(:quiz, questions_attributes: [attributes_for(:question)]))
    question = quiz.questions.first

    @quizzes.destroy(quiz.id)

    refute question.exists?
  end

  def test_destroying_scopes_to_user
    quiz = create(:quiz, creator: create(:matija))

    assert_raises(Kvizovi::Error::NotFound) { @quizzes.destroy(quiz.id) }
  end
end
