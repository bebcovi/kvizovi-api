require "sequel"
require "yaml"

db_config = YAML.load_file("config/database.yml")
db_config = db_config.fetch(ENV["RACK_ENV"] || "development")
db_config.merge!("username" => ENV["USER"])

DB = Sequel.connect(db_config)
