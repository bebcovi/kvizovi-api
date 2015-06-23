require "sequel"
require "yaml"

db_config = YAML.load_file("config/database.yml")
db_config = db_config.fetch(ENV["RACK_ENV"] || "development")
db_config.merge!("username" => ENV["USER"])

DB = Sequel.connect(db_config)

DB.extension :pg_array
DB.extension :pg_json
DB.extension :pagination

Sequel::Model.raise_on_save_failure = true

Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :nested_attributes
Sequel::Model.plugin :pg_array_associations
Sequel::Model.plugin :tactical_eager_loading

module Kvizovi
  module Models
    Base = Sequel::Model
  end
end
