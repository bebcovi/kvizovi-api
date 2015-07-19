Sequel.migration do
  up do
    run "CREATE EXTENSION citext"
  end

  down do
    run "DROP EXTENSION citext"
  end
end
