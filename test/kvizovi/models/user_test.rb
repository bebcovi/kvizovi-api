require "unit"
require "kvizovi/models"

class UserTest < Minitest::Test
  include TestHelpers::Unit

  def test_elasticsearch_indexing
    Kvizovi::ElasticsearchIndex.noop = false

    quiz = create(:quiz, creator: create(:janko))
    quiz.creator.update(name: "Changed name")
    results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
    assert_equal "Changed name", results.fetch(0)["creator"]["name"]
  end
end
