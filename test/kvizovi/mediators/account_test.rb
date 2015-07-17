require "unit"
require "kvizovi/mediators/account"
require "kvizovi/mediators/quizzes"
require "timecop"
require "as-duration"

BCrypt::Engine.cost = 1
SimpleMailer.test_mode!

Account = Kvizovi::Mediators::Account

class RegistrationTest < Minitest::Test
  include TestHelpers::Unit

  def test_mass_assignment
    assert_raises(Kvizovi::Error::InvalidAttribute) do
      Account.register!(created_at: Time.now)
    end
  end

  def test_password_encrypting
    user = Account.register!(attributes_for(:janko))

    refute_empty user.encrypted_password
    refute_equal user.password, user.encrypted_password
  end

  def test_confirmation_token
    user = Account.register!(attributes_for(:janko))

    refute_empty user.confirmation_token
  end

  def test_authentication_token
    user = Account.register!(attributes_for(:janko))

    refute_empty user.token
  end

  def test_persisting
    user = Account.register!(attributes_for(:janko, creator_id: create(:matija).id))

    refute user.new?
    assert_kind_of Integer, user.creator_id
  end

  def test_confirmation_email
    user = Account.register!(attributes_for(:janko))

    refute_empty sent_emails
  end

  def test_confirmation
    user = Account.register!(attributes_for(:janko))
    user = Account.confirm!(user.confirmation_token)

    assert_instance_of Time, user.confirmed_at
    assert_nil user.confirmation_token
  end

  def test_validation
    invalid { Account.register!(attributes_for(:janko, name: nil)) }
    invalid { Account.register!(attributes_for(:janko, email: nil)) }
    invalid { Account.register!(attributes_for(:janko, password: nil)) }

    user = Account.register!(attributes_for(:janko))
    invalid { Account.register!(attributes_for(:matija, name: user.name)) }
    invalid { Account.register!(attributes_for(:matija, email: user.email)) }
  end
end

class AuthenticationTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
  end

  def test_success
    user = Account.authenticate([@user.email, @user.password])

    assert_instance_of Kvizovi::Models::User, user
  end

  def test_authenticating_with_username
    @user.update(username: "janko")

    Account.authenticate([@user.username, @user.password])
  end

  def test_invalid_password
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.authenticate([@user.email, "incorrect password"])
    end
  end

  def test_invalid_email
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.authenticate(["incorrect@email.com", @user.password])
    end
  end

  def test_invalid_token
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.authenticate(:token, "incorrect")
    end
  end

  def test_account_expiration
    Timecop.travel(4.days.from_now) do
      assert_raises(Kvizovi::Error::Unauthorized) do
        Account.authenticate([@user.email, @user.password])
      end
    end
  end

  def test_invalid_confirmation_token
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.authenticate(:confirmation_token, "incorrect")
    end
  end

  def test_invalid_password_reset_token
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.authenticate(:password_reset_token, "incorrect")
    end
  end
end

class PasswordResetTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
  end

  def test_password_reset_token
    user = Account.reset_password!(@user.email)

    refute_empty user.password_reset_token
  end

  def test_password_reset_instructions
    user = Account.reset_password!(@user.email)

    refute_empty sent_emails
  end

  def test_nonexisting_email
    assert_raises(Kvizovi::Error::Unauthorized) do
      Account.reset_password!("nonexisting@email.com")
    end
  end
end

class PasswordSetTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
    @user = Account.reset_password!(@user.email)
  end

  def test_mass_assignment
    assert_raises(Kvizovi::Error::InvalidAttribute) do
      Account.set_password!(@user.password_reset_token, created_at: nil)
    end
  end

  def test_password_encrypting
    old_password = @user.encrypted_password

    user = Account.set_password!(@user.password_reset_token, password: "new secret")

    refute_empty user.encrypted_password
    refute_equal old_password, user.encrypted_password
  end

  def test_nullifying_password_reset_token
    user = Account.set_password!(@user.password_reset_token, password: "new secret")

    assert_nil user.password_reset_token
  end
end

class AccountUpdateTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
    @user.password = nil
    @account = Account.new(@user)
  end

  def test_mass_assignment
    @account.update!(attributes_for(:janko, password: nil))
    assert_raises(Kvizovi::Error::InvalidAttribute) { @account.update!(created_at: nil) }
  end

  def test_password_update
    old_password = @user.encrypted_password

    @account.update!({})

    assert_equal old_password, @user.encrypted_password

    @account.update!(password: "new secret", old_password: attributes_for(:janko)[:password])

    refute_empty @user.encrypted_password
    refute_equal old_password, @user.encrypted_password
  end

  def test_elasticsearch_indexing
    elastic do
      Kvizovi::Mediators::Quizzes.new(@user).create(attributes_for(:quiz))
      @account.update!(name: "Changed name")
      results = Kvizovi::ElasticsearchIndex[:quiz].search("*")
      assert_equal "Changed name", results.fetch(0)["creator"]["name"]
    end
  end

  def test_validation
    invalid { @account.update!(attributes_for(:janko, name: nil)) }
    invalid { @account.update!(attributes_for(:janko, email: nil)) }

    user = Account.register!(attributes_for(:matija))
    invalid { @account.update!(name: user.name) }
    invalid { @account.update!(email: user.email) }

    invalid { @account.update!(password: "new secret") }
  end

  def test_creator_assignment
    @account.update!(creator_id: create(:matija).id)

    assert_kind_of Integer, @user.creator_id
  end
end

class AccountDestructionTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
    @account = Account.new(@user)
  end

  def test_user_destruction
    @account.destroy!

    refute @user.exists?
  end

  def test_quizzes_destruction
    quiz = create(:quiz, creator: @user)

    @account.destroy!

    refute quiz.exists?
  end

  def test_gameplays_destruction
    gameplay = create(:gameplay, player_ids: [@user.id])

    @account.destroy!

    refute gameplay.exists?
  end
end

class AccountInfoTest < Minitest::Test
  include TestHelpers::Unit

  def setup
    super
    @user = Account.register!(attributes_for(:janko))
    @account = Account.new(@user)
  end

  def test_players
    matija = create(:matija, creator: @user)

    assert_equal [matija], @account.players.to_a
  end
end
