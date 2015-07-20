namespace :legacy do
  task :setup do
    require "kvizovi/configuration/sequel"

    DB.extension :pg_array, :pg_json
    Sequel.extension :pg_array_ops, :pg_json_ops

    @legacy_db = Sequel.connect("postgres:///kvizovi_legacy")
    @legacy_db.extension :pg_array

    require_relative "legacy"
  end

  task :migrate => [:setup] do
    Legacy::Migrate.call(DB, @legacy_db)
  end
end
