require "sequel_postgresql_triggers"

Sequel.migration do
  up do
    create_table :questions do
      primary_key :id

      column :quiz_id, :integer

      column :type,     :varchar
      column :title,    :varchar
      column :content,  :jsonb
      column :image_id, :varchar
      column :hint,     :varchar

      column :position, :integer

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
