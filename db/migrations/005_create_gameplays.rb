Sequel.migration do
  change do
    create_table :gameplays do
      primary_key :id
      foreign_key :quiz_id, :quizzes

      column :quiz_snapshot, :jsonb,      null: false
      column :player_ids,    "integer[]", null: false
      column :answers,       :jsonb,      null: false

      column :started_at,  :timestamp, null: false
      column :finished_at, :timestamp, null: false
    end
  end
end
