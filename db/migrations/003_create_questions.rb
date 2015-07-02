require "sequel_postgresql_triggers"

Sequel.migration do
  up do
    create_table :questions do
      primary_key :id
      foreign_key :quiz_id, :quizzes

      column :kind,     :varchar, null: false
      column :title,    :varchar, null: false
      column :content,  :jsonb,   null: false
      column :image_id, :varchar
      column :hint,     :varchar

      column :position, :integer, null: false

      column :created_at, :timestamp
      column :updated_at, :timestamp
    end

    pgt_counter_cache(:quizzes, :id, :questions_count, :questions, :quiz_id, trigger_name: :questions_counter)
  end

  down do
    drop_trigger :questions, :questions_counter
    drop_table :questions
  end
end
