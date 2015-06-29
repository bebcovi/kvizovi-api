Sequel.migration do
  change do
    create_table :users do
      primary_key :id

      column :name,               :varchar, null: false, unique: true
      column :email,              :varchar, null: false, unique: true
      column :avatar_id,          :varchar
      column :encrypted_password, :varchar
      column :token,              :varchar

      column :confirmation_token, :varchar
      column :confirmed_at,       :timestamp

      column :password_reset_token, :varchar

      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end
end
