require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

namespace :db do
  task :migrate, [:version] do |task, args|
    sequel migrate: (args[:version] || true)
  end

  task :demigrate do
    sequel migrate: 0
  end

  task :remigrate => [:demigrate, :migrate]

  def sequel(migrate: nil)
    args = []

    if migrate
      args += %W[--migrate-directory db/migrations]
      args += %W[--migrate-version #{migrate}] if Integer === migrate
    end

    args += %W[--env #{ENV["RACK_ENV"] || "test"} config/database.yml]

    sh ["sequel", *args].join(" ")
  end
end

task :console do
  ARGV.clear

  require "kvizovi"
  require "pry"
  require "logger"

  include Kvizovi::Models
  DB.logger = Logger.new(STDOUT)
  DB.transaction(rollback: :always) { Pry.start }
end
