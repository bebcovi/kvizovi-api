Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      foreign_key :creator_id, :users

      column :name,               :varchar, null: false, unique: true
      column :email,              :citext,  null: false, unique: true
      column :username,           :varchar,              unique: true
      column :avatar_id,          :varchar
      column :avatar_filename,    :varchar
      column :encrypted_password, :varchar
      column :token,              :varchar

      column :confirmation_token, :varchar
      column :confirmed_at,       :timestamp

      column :password_reset_token, :varchar

      column :created_at, :timestamp, null: false
      column :updated_at, :timestamp, null: false
    end
  end
end
