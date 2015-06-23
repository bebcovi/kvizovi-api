require "unit"
require "kvizovi/models"

class QuizTest < Minitest::Test
  include TestHelpers::Unit

  def test_elasticsearch_indexing
    Kvizovi::ElasticsearchIndex.noop = false

    quiz = create(:quiz, creator: create(:janko))
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    assert_equal quiz.id, results.fetch(0)["id"]

    quiz.update(name: "Changed name")
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    assert_equal "Changed name", results.fetch(0)["name"]

    quiz.destroy
    assert_empty Kvizovi::ElasticsearchIndex[:quiz].search("*")
  end
end
