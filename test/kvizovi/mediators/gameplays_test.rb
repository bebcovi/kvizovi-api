require "unit"
require "kvizovi/mediators/gameplays"

Gameplays = Kvizovi::Mediators::Gameplays

class GameplaysTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = create(:janko)
    @quiz = create(:quiz, creator: @user)
    @gameplays = Gameplays.new(@user)
  end

  def create_gameplay(quiz: @quiz, players: [@user], **options)
    Gameplays.create(attributes_for(:gameplay,
      associations: {quiz: quiz.id, players: players.map(&:id)}).merge(options))
  end

  def test_creating
    gameplay = create_gameplay

    refute gameplay.new?
    assert_equal @quiz, gameplay.quiz
    assert_equal [@user], gameplay.players
  end

  def test_searching_as_creator
    matija = create(:matija, creator: @user)
    dori   = create(:dori,   creator: @user)

    dummy_gameplay = create_gameplay(players: [@user])
    gameplays = [
      create_gameplay(players: [matija]),
      create_gameplay(players: [@user, matija]),
      create_gameplay(players: [dori, matija]),
    ]

    assert_equal gameplays, @gameplays.search(as: "creator").to_a
    assert_equal gameplays, @gameplays.search(as: "creator", quiz_id: @quiz.id).to_a
    assert_equal [],        @gameplays.search(as: "creator", quiz_id: -1).to_a
  end

  def test_searching_as_player
    gameplay = create_gameplay
    @user.remove_all_quizzes

    assert_equal [gameplay], @gameplays.search(as: "player").to_a
    assert_equal [gameplay], @gameplays.search(as: "player", quiz_id: gameplay.quiz.id).to_a
    assert_equal [],         @gameplays.search(as: "player", quiz_id: -1).to_a
  end

  def test_pagination
    gameplay1 = create_gameplay
    gameplay2 = create_gameplay

    assert_equal [gameplay1], @gameplays.search(as: "player", page: {number: 1, size: 1}).to_a
    assert_equal [gameplay2], @gameplays.search(as: "player", page: {number: 2, size: 1}).to_a
  end

  def test_find
    gameplay = create_gameplay

    assert_equal gameplay, @gameplays.find(gameplay.id)
  end

  def test_not_found
    assert_raises(Kvizovi::Error::NotFound) { @gameplays.find(-1) }
  end

  def test_validation
    Gameplays.validate(build(:gameplay))

    invalid { Gameplays.validate(build(:gameplay, quiz_snapshot: nil)) }
    invalid { Gameplays.validate(build(:gameplay, answers: nil)) }
    invalid { Gameplays.validate(build(:gameplay, started_at: nil)) }
    invalid { Gameplays.validate(build(:gameplay, finished_at: nil)) }
  end

  def test_create_calls_validation
    invalid { create_gameplay(quiz_snapshot: nil) }
  end

  def test_mass_assignment
    assert_raises(Kvizovi::Error::InvalidAttribute) { create_gameplay(id: nil) }
  end
end
