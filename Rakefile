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

    sh ["sequel", *args, "--env test", "config/database.yml"].join(" ")
    sh ["sequel", *args, "--env development", "config/database.yml"].join(" ")
  end
end

namespace :elastic do
  desc "Create Elaticsearch index and import the records"
  task :setup => [:create, :import]

  desc "Create the Elasticsearch index"
  task :create do
    require "kvizovi"
    Kvizovi::ElasticsearchIndex.create!
  end

  desc "Import all existing quizzes to Elasticsearch"
  task :import do
    require "kvizovi"
    Kvizovi::Models::Quiz.dataset.each_page(1000) do |quizzes|
      Kvizovi::ElasticsearchIndex[:quiz].index(quizzes)
    end
  end
end

desc "Start the console with app loaded, in sandbox mode"
task :console do
  ARGV.clear

  require "kvizovi"
  require "pry"
  require "logger"

  include Kvizovi::Models
  DB.logger = Logger.new(STDOUT)
  Pry.start
end
