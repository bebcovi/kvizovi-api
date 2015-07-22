Sequel.migration do
  change do
    create_table :quizzes do
      primary_key :id
      foreign_key :creator_id, :users

      column :name,            :varchar, null: false
      column :category,        :varchar, null: false
      column :image_id,        :varchar
      column :image_filename,  :varchar
      column :shuffle,         :boolean, default: false
      column :questions_count, :integer, default: 0

      column :created_at, :timestamp, null: false
      column :updated_at, :timestamp, null: false
    end
  end
end
