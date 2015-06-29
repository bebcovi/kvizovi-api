Sequel.migration do
  change do
    create_table :quizzes do
      primary_key :id
      foreign_key :creator_id, :users

      column :name,            :varchar, null: false
      column :category,        :varchar, null: false
      column :image_id,        :varchar
      column :active,          :boolean, default: false
      column :questions_count, :integer

      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end
end
