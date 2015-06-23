require "unit"
require "kvizovi/models"

class QuestionTest < Minitest::Test
  include TestHelpers::Unit

  def test_elasticsearch_indexing
    Kvizovi::ElasticsearchIndex.noop = false

    question = create(:question, quiz: create(:quiz, creator: create(:janko)))
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    refute_empty results.fetch(0)["questions"]

    question.update(title: "Changed title")
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    assert_equal "Changed title", results.fetch(0)["questions"][0]["title"]

    question.destroy
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    assert_empty results.fetch(0)["questions"]
  end
end
