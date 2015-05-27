Sequel.migration do
  change do
    create_table :users do
      primary_key :id

      column :nickname,           :varchar
      column :avatar_id,          :varchar
      column :email,              :varchar
      column :encrypted_password, :varchar
      column :token,              :varchar

      column :teacher_id, :integer

      column :confirmation_token, :varchar
      column :confirmed_at,       :timestamp

      column :password_reset_token, :varchar

      column :created_at, :timestamp
      column :updated_at, :timestamp
    end
  end
end
