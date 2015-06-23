require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :db do
  desc "Migrate the database (you can specify the version with `db:migrate[N]`)"
  task :migrate, [:version] do |task, args|
    sequel migrate: (args[:version] || true)
  end

  desc "Undo all migrations"
  task :demigrate do
    sequel migrate: 0
  end

  desc "Undo all migrations and migrate again"
  task :remigrate => [:demigrate, :migrate]

  desc "Print out the current database schema"
  task :schema do
    sequel "--dump-migration-same-db"
  end

  def sequel(*args, migrate: nil)
    if migrate
      args += %W[--migrate-directory db/migrations]
      args += %W[--migrate-version #{migrate}] if String === migrate
    end

    args += %W[--env #{ENV["RACK_ENV"] || "test"} config/database.yml]

    sh ["sequel", *args].join(" ")
  end
end

desc "Start the console with app loaded, in sandbox mode"
task :console do
  ARGV.clear
  ENV["RACK_ENV"] = "test"

  require "kvizovi"
  require "pry"
  require "logger"

  include Kvizovi::Models
  DB.logger = Logger.new(STDOUT)
  DB.transaction(rollback: :always) { Pry.start }
end
