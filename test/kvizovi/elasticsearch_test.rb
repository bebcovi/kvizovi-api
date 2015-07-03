require "unit"
require "kvizovi/elasticsearch"
require "elasticsearch"
require "ostruct"

ElasticsearchIndex = Kvizovi::ElasticsearchIndex

class ElasticsearchTest < Minitest::Test
  include TestHelpers::Unit

  elastic!

  def test_creating_index
    ElasticsearchIndex.stub(:index_name, "kvizovi_test") do
      ElasticsearchIndex.create!

      assert client.indices.exists?(index: "kvizovi_test")
    end
  end

  def test_recreating_index
    ElasticsearchIndex.stub(:index_name, "kvizovi_test") do
      ElasticsearchIndex.create!
      ElasticsearchIndex.create!
    end
  end

  def test_deleting_index
    ElasticsearchIndex.stub(:index_name, "kvizovi_test") do
      ElasticsearchIndex.create!
      ElasticsearchIndex.delete!

      refute client.indices.exists?(index: "kvizovi_test")
    end
  end

  def test_deleting_nonexisting_index
    ElasticsearchIndex.stub(:index_name, "kvizovi_test") do
      ElasticsearchIndex.create!
      ElasticsearchIndex.delete!
      ElasticsearchIndex.delete!
    end
  end

  def test_creating_quizzes
    ElasticsearchIndex[:quiz].index(quiz)
    assert_equal 1, indexed_quizzes.count
    client.delete(index: "kvizovi", type: "quiz", id: quiz.id)

    ElasticsearchIndex[:quiz].index([quiz])
    assert_equal 1, indexed_quizzes.count
  end

  def test_updating_quizzes
    ElasticsearchIndex[:quiz].index(quiz)

    quiz.name = "Changed name"
    ElasticsearchIndex[:quiz].index(quiz)
    assert_equal "Changed name", indexed_quizzes.first.fetch("name")

    quiz.name = "Another changed name"
    ElasticsearchIndex[:quiz].index([quiz])
    assert_equal "Another changed name", indexed_quizzes.first.fetch("name")
  end

  def test_deleting_quizzes
    ElasticsearchIndex[:quiz].index(quiz)
    ElasticsearchIndex[:quiz].delete(quiz)
    assert_empty indexed_quizzes

    ElasticsearchIndex[:quiz].index(quiz)
    ElasticsearchIndex[:quiz].delete([quiz])
    assert_empty indexed_quizzes
  end

  def test_searching_quizzes
    quiz.name = "World"
    quiz.questions.first.title = "Bunnies are so cute!"
    quiz.questions.first.content = {choices: ["That wasn't a question"]}
    quiz.creator.name = "Person"
    ElasticsearchIndex[:quiz].index(quiz)

    assert_instance_of Array, ElasticsearchIndex[:quiz].search("*")

    refute_empty ElasticsearchIndex[:quiz].search("world")
    refute_empty ElasticsearchIndex[:quiz].search("bunnies")
    refute_empty ElasticsearchIndex[:quiz].search("question")
    refute_empty ElasticsearchIndex[:quiz].search("person")
  end

  def test_search_ranking
    quiz1 = O(id: 1, name: "World", questions: [])
    quiz2 = O(id: 2, questions: [O(title: "World")])
    ElasticsearchIndex[:quiz].index([quiz2, quiz1])

    results = ElasticsearchIndex[:quiz].search("World")

    assert_equal quiz1.id, results[0]["id"]
    assert_equal quiz2.id, results[1]["id"]
  end

  private

  def client
    @client ||= Elasticsearch::Client.new
  end

  def quiz
    @quiz ||= O(
      id: 1,
      name: "Quiz",
      questions: [O(title: "Question", content: {})],
      creator: O(name: "Creator"),
    )
  end

  def O(*args)
    OpenStruct.new(*args)
  end

  def indexed_quizzes
    client.search(index: "kvizovi")["hits"]["hits"].map { |hash| hash["_source"] }
  end
end
