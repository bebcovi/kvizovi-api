require "integration"

require "pry"
require "mini_magick"

class AppTest < Minitest::Test
  include TestHelpers::Integration

  elastic!

  def test_registration
    post "/account", data: json_attributes_for(:janko)
    assert_resource response.resource("user")

    patch email_link
    assert_resource response.resource("user")
  end

  def test_authentication
    register!

    get "/account", {}, basic_auth(email, password)
    assert_resource response.resource("user")

    get "/account", {}, token_auth(token)
    assert_resource response.resource("user")
  end

  def test_password_reset
    register!

    post "/account/password?email=#{email}"
    patch email_link, data: {type: "users", attributes: {password: "another secret"}}
    assert_resource response.resource("user")

    get "/account", {}, basic_auth(email, "another secret")
    assert_resource response.resource("user")
  end

  def test_password_update
    register!

    patch "/account",
      {data: {type: "users", attributes: {old_password: password, password: "new secret"}}},
      token_auth(token)

    get "/account", {}, basic_auth(email, "new secret")
    assert_resource response.resource("user")
  end

  def test_deleting_account
    register!

    delete "/account", {}, token_auth(token)

    get "/account", {}, basic_auth(email, password)
    assert_equal 401, response.status
    assert_equal "credentials_invalid", response.error["id"]
  end

  def test_account_info
    register!
    creator_id = response.resource("user")["id"]

    post "/account", data: json_attributes_for(:matija).merge(
      relationships: {creator: {data: {type: "users", id: creator_id}}})
    player_id = response.resource("user")["id"]

    get "/account/players", {}, token_auth(token)
    assert_equal player_id, response.resource("user")["id"]

    get "/account", {include: "creator"}, token_auth(response.resource("user")["token"])
    assert_equal creator_id, response.resource("user")["creator"]["id"]
  end

  def test_managing_quizzes
    register!

    post "/quizzes?include=questions,creator",
      {data: json_attributes_for(:quiz, name: "Game of Thrones", category: "movies",
        questions_attributes: [attributes_for(:question)])}, token_auth(token)
    assert_resource response.resource("quiz")
    assert_resource response.resource("quiz").fetch("questions")[0]
    assert_resource response.resource("quiz").fetch("creator")

    quiz_id = response.resource("quiz")["id"]

    get "/quizzes", {q: "game"}
    assert_resource response.resource("quiz")

    get "/quizzes", {category: "movies"}
    assert_resource response.resource("quiz")

    get "/quizzes", {page: {number: 1, size: 1}}
    assert_resource response.resource("quiz")

    get "/quizzes", {}, token_auth(token)
    assert_resource response.resource("quiz")

    get "/quizzes/#{quiz_id}", token_auth(token)
    assert_resource response.resource("quiz")

    patch "/quizzes/#{quiz_id}",
      {data: {attributes: {name: "New name"}}}, token_auth(token)
    assert_equal "New name", response.resource("quiz")["name"]

    delete "/quizzes/#{quiz_id}", {}, token_auth(token)
    get "/quizzes/#{quiz_id}", {}, token_auth(token)
    assert_equal 404, response.status
  end

  def test_managing_questions
    register!

    post "/quizzes", {data: json_attributes_for(:quiz)}, token_auth(token)
    quiz_id = response.resource("quiz")["id"]

    post "/quizzes/#{quiz_id}/questions",
      {data: json_attributes_for(:question)}, token_auth(token)
    assert_resource response.resource("question")
    question_id = response.resource("question")["id"]

    get "/quizzes/#{quiz_id}/questions", {}, token_auth(token)
    assert_resource response.resources("questions")[0]

    get "/quizzes/#{quiz_id}/questions/#{question_id}", {include: "quiz"}, token_auth(token)
    assert_resource response.resource("question")
    assert_resource response.resource("question")["quiz"]

    patch "/quizzes/#{quiz_id}/questions/#{question_id}",
      {data: {attributes: {title: "New title"}}}, token_auth(token)
    assert_equal "New title", response.resource("question")["title"]

    delete "/quizzes/#{quiz_id}/questions/#{question_id}", {}, token_auth(token)
    get "/quizzes/#{quiz_id}/questions/#{question_id}", {}, token_auth(token)
    assert_equal 404, response.status
  end

  def test_gameplays
    register!
    user_id = response.resource("user")["id"]

    post "/quizzes", {data: json_attributes_for(:quiz)}, token_auth(token)
    quiz_id = response.resource("quiz")["id"]

    post "/gameplays?include=players,quiz", {
      data: json_attributes_for(:gameplay).merge(
        relationships: {
          quiz: {data: {type: "quizzes", id: quiz_id}},
          players: {data: [{type: "users", id: user_id}]},
        }
      )
    }, token_auth(token)
    assert_resource response.resource("gameplay")
    assert_resource response.resource("gameplay").fetch("players")[0]
    assert_resource response.resource("gameplay").fetch("quiz")
    gameplay_id = response.resource("gameplay")["id"]

    get "/gameplays", {as: "player"}, token_auth(token)
    assert_resource response.resources("gameplays")[0]

    get "/gameplays", {as: "player", page: {number: 1, size: 1}}, token_auth(token)
    assert_resource response.resources("gameplays")[0]

    get "/gameplays/#{gameplay_id}", {}, token_auth(token)
    assert_resource response.resource("gameplay")
  end

  def test_image_upload
    post_original "/account", data: json_attributes_for(:janko, avatar: image)
    avatar_url = response.resource("user").fetch("avatar_url")
    avatar_url.gsub!(/\{\w+\}/, "{width}"=>"50", "{height}"=>"50")
    avatar_path = URI(avatar_url).path

    get avatar_path

    assert_equal 200, response.status
    avatar = MiniMagick::Image.read(response.body)
    assert avatar.width <= 50
    assert avatar.height <= 50
  end

  def test_contact
    post "/contact", data: {type: "emails", attributes: {from: "foo@bar.com", body: "Hello"}}

    assert_includes sent_emails.last[:message], "foo@bar.com"
    assert_includes sent_emails.last[:message], "Hello"
  end

  def test_heartbeat
    head "/heartbeat"

    assert_equal 200, response.status
  end

  def test_errors
    register!

    patch "/account"
    assert_equal 401, response.status
    assert_equal "token_missing", response.error["id"]

    patch "/account", {}, token_auth("foo")
    assert_equal 401, response.status
    assert_equal "token_invalid", response.error["id"]

    get "/quizzes/-1"
    assert_equal 404, response.status
    assert_equal "resource_not_found", response.error["id"]

    get "/gameplays"
    assert_equal 400, response.status
    assert_equal "param_missing", response.error["id"]

    post "/quizzes", {data: {type: "quizzes", attributes: {foo: "bar"}}}, token_auth(token)
    assert_equal 400, response.status
    assert_equal "invalid_attribute", response.error["id"]

    post "/quizzes", {data: {type: "quizzes", attributes: {}}}, token_auth(token)
    assert_equal 400, response.status
    assert_equal "validation_failed", response.error["id"]
    assert_nonempty Array, response.error.fetch("meta")["errors"]

    get "/foo"
    assert_equal 404, response.status
    assert_equal "page_not_found", response.error["id"]
  end

  private

  def register!
    user_data = json_attributes_for(:janko)
    post "/account", data: user_data
    @email = user_data.fetch(:attributes).fetch(:email)
    @password = user_data.fetch(:attributes).fetch(:password)
    @token = response.resource("user").fetch("token")
  end

  attr_reader :email, :password, :token
end
