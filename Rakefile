require "rake/testtask"
require "yaml"

import "tasks/legacy.rake"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :db do
  desc "Migrate the database (you can specify the version with `db:migrate[N]`)"
  task :migrate, [:version] do |task, args|
    version = args[:version] ? Integer(args[:version]) : nil
    migrate(version)
    dump_schema
  end

  desc "Undo all migrations"
  task :demigrate do
    migrate(0)
    dump_schema
  end

  desc "Undo all migrations and migrate again"
  task :remigrate do
    migrate(0)
    migrate
    dump_schema
  end

  def migrate(version = nil)
    Sequel.extension :migration
    environments { Sequel::Migrator.apply(DB, "db/migrations", version) }
  end

  def dump_schema
    require "kvizovi/configuration/sequel"
    system "pg_dump #{DB.opts[:database]} > db/schema.sql"
    DB.extension :schema_dumper
    File.write("db/schema.rb", DB.dump_schema_migration(same_db: true))
  end

  def environments
    YAML.load_file("config/database.yml").keys.each do |env|
      next if env == "defaults"
      begin
        ENV["RACK_ENV"] = env
        require "kvizovi/configuration/sequel"
        yield
      rescue Sequel::DatabaseConnectionError
      ensure
        $LOADED_FEATURES.reject! { |path| path.include?("kvizovi/configuration/sequel") }
        Object.send(:remove_const, :DB) if Object.const_defined?(:DB)
        ENV.delete("RACK_ENV")
      end
    end
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
