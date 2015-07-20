require "kvizovi"
require "kvizovi/configuration/credentials"

require "memoizable"
require "inflecto"
require "active_support/hash_with_indifferent_access"
require "aws-sdk"

require "securerandom"
require "ostruct"
require "json"

module Legacy
  class Migrate
    include Memoizable

    def self.call(db, legacy_db)
      new(db, legacy_db).call
    end

    def initialize(db, legacy_db)
      @db, @legacy_db = db, legacy_db
      @question_images = {}
    end

    def call
      clear!
      migrate_users!
      migrate_quizzes!
      migrate_questions!
      migrate_gameplays!
    end

    private

    attr_reader :db, :legacy_db, :question_images

    def clear!
      clear_tables!
      clear_uploads!
    end

    def clear_tables!
      db.tables.each do |table|
        db[table].truncate(cascade: true) unless table == :schema_info
        if db[table].columns.include?(:id)
          db.run "ALTER SEQUENCE #{table}_id_seq RESTART WITH 1"
        end
      end
    end

    def clear_uploads!
      Refile.store.clear!(:confirm)
    end

    def migrate_users!
      migrate_schools!
      migrate_students!
    end

    def migrate_schools!
      users = legacy_db[:schools].map { |school| translate_school(school) }

      db[:users].multi_insert(users)
    end

    def migrate_students!
      users = legacy_db[:students]
        .where(id:
          legacy_db[:students___s]
            .where{trim(first_name) =~ trim(:students__first_name)}
            .where{trim(last_name) =~ trim(:students__last_name)}
            .select{max(id)}
        )
        .exclude(
          legacy_db[:schools].where(email: :students__email).exists
        )
        .exclude(first_name: "Matija", last_name: "Marohnić")
        .map { |student| translate_student(student)  }

      db[:users].multi_insert(users)
    end

    def migrate_quizzes!
      quizzes = legacy_db[:quizzes].order(:id).map { |quiz| translate_quiz(quiz) }

      db[:quizzes].multi_insert(quizzes)
    end

    def migrate_questions!
      questions = legacy_db[:questions].map { |question| translate_question(question) }

      questions.each { |question| db[:questions].insert(question) }
    end

    def migrate_gameplays!
      snapshots = legacy_db[:quiz_snapshots].where(id: :quiz_snapshot_id)

      gameplays = legacy_db[:played_quizzes]
        .select_append(
          snapshots.select(:quiz_id).as(:quiz_id),
          snapshots.select(:quiz_attributes).as(:quiz_attributes),
          snapshots.select(:questions_attributes).as(:questions_attributes),
        )
        .select_append(
          legacy_db
            .from(
              legacy_db[:playings]
                .where(played_quiz_id: :played_quizzes__id)
                .select(:player_id)
                .order(:position)
            )
            .select{array_agg(:player_id)}
            .as(:player_ids)
        )
        .where(has_answers: true, interrupted: false)
        .map { |played_quiz| translate_played_quiz(played_quiz) }
        .reject(&:nil?)

      db[:gameplays].multi_insert(gameplays)
    end

    def translate_school(school)
      {
        name: (
          if !school.fetch(:name).empty?
            school[:name]
          elsif school[:id] == 15
            "Prelog"
          elsif school[:id] == 54
            "Medicinska škola"
          else
            raise "School #{school[:id]} doesn't have a name"
          end
        ),
        username:           school.fetch(:username).strip,
        email:              school.fetch(:email).strip,
        token:              SecureRandom.hex,
        encrypted_password: school.fetch(:encrypted_password),
        confirmation_token: school.fetch(:confirmation_token),
        confirmed_at:       school.fetch(:confirmed_at),
        created_at:         school.fetch(:created_at),
        updated_at:         school.fetch(:updated_at),
      }
    end

    def translate_student(student)
      {
        name:               student.values_at(:first_name, :last_name).map(&:strip).join(" "),
        username:           student.fetch(:username).strip,
        email:              (student.fetch(:email) || "janko.marohnic+kvizovi-#{student[:id]}gmail.com").strip,
        token:              SecureRandom.hex,
        creator_id:         school_mapping.fetch(student.fetch(:school_id)),
        encrypted_password: student.fetch(:encrypted_password),
        confirmation_token: student.fetch(:confirmation_token),
        confirmed_at:       student.fetch(:confirmed_at),
        created_at:         student.fetch(:created_at),
        updated_at:         student.fetch(:updated_at),
      }
    end

    def translate_quiz(quiz)
      {
        name:       quiz.fetch(:name).strip,
        category:   "literature",
        creator_id: school_mapping.fetch(quiz.fetch(:school_id)),
        active:     quiz.fetch(:activated),
        shuffle:    quiz.fetch(:shuffle_questions),
        created_at: quiz.fetch(:created_at),
        updated_at: quiz.fetch(:updated_at),
      }
    end

    def translate_question(question)
      {
        title:      question.fetch(:content),
        content:    (
          data = YAML.load(question.fetch(:data))
          data.reject! { |key, value| key.to_s.start_with?("image_") }
          Sequel.pg_jsonb(data)
        ),
        position:   question.fetch(:position) || 1,
        quiz_id:    quiz_mapping.fetch(question.fetch(:quiz_id)),
        kind:       Inflecto.underscore(question.fetch(:type).chomp("Question")),
        hint:       question.fetch(:hint),
        created_at: question.fetch(:created_at),
        updated_at: question.fetch(:updated_at),
        **upload_image(question),
      }
    end

    def translate_played_quiz(played_quiz)
      return nil if not quiz_mapping.key?(played_quiz[:quiz_id])
      return nil if played_quiz[:player_ids].nil?

      {
        quiz_id:       quiz_mapping.fetch(played_quiz.fetch(:quiz_id)),
        quiz_snapshot: (
          quiz = symbolize_keys(YAML.load(played_quiz.fetch(:quiz_attributes)))
          quiz = Kvizovi::Models::Quiz.new(translate_quiz(quiz))

          quiz.questions_attributes = YAML.load(played_quiz.fetch(:questions_attributes))
            .map { |attributes| symbolize_keys(attributes) }
            .each { |attributes| attributes[:data] = YAML.dump(attributes[:data]) }
            .map { |question| translate_question(question) }

          request = OpenStruct.new(env: {"QUERY_STRING" => "include=questions"})
          json_string = Kvizovi::Serializer.call(quiz, request)
          Sequel.pg_jsonb(JSON.parse(json_string))
        ),
        player_ids:    Sequel.pg_array(played_quiz.fetch(:player_ids)),
        answers:       Sequel.pg_jsonb(YAML.load(played_quiz.fetch(:question_answers))),
        started_at:    played_quiz.fetch(:begin_time),
        finished_at:   played_quiz.fetch(:end_time),
      }
    end

    def school_mapping
      legacy_school_mapping = legacy_db[:schools].select_hash(:id, :email)
      new_school_mapping    = db[:users].where(creator_id: nil).select_hash(:email, :id)

      legacy_school_mapping.inject({}) do |hash, (id, email)|
        hash.update(id => new_school_mapping.fetch(email))
      end
    end
    memoize :school_mapping

    def quiz_mapping
      legacy_ids = legacy_db[:quizzes].order(:id).map(:id)
      ids        = db[:quizzes].order(:id).map(:id)

      Hash[legacy_ids.zip(ids)]
    end
    memoize :quiz_mapping

    def upload_image(question)
      question_images.fetch(question[:id]) do
        question_images[question[:id]] =
          if question[:image]
            image_path = "question/#{question[:id]}/image/#{question[:image]}"
            image_object = legacy_s3_bucket.object(image_path)
            image = image_object.get.body

            file = Refile.store.upload(image)
            filename = File.basename(image_path[/^.+\.(jpg|gif|png)/] || image_path)

            {image_id: file.id, image_filename: filename}
          else
            {}
          end
      end
    end

    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    def legacy_s3_bucket
      legacy_s3 ||= Aws::S3::Resource.new(
        access_key_id:     ENV.fetch("LEGACY_AMAZON_S3_ACCESS_KEY_ID"),
        secret_access_key: ENV.fetch("LEGACY_AMAZON_S3_SECRET_ACCESS_KEY"),
        region:            ENV.fetch("LEGACY_AMAZON_S3_REGION"),
      )
      legacy_s3.bucket ENV.fetch("LEGACY_AMAZON_S3_BUCKET")
    end
    memoize :legacy_s3_bucket
  end
end
