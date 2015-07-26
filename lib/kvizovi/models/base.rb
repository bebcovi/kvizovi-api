require "kvizovi/configuration/sequel"

DB.extension :pg_array, :pg_json, :pagination

Sequel::Model.raise_on_save_failure = true

Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :timestamps, update_on_create: true
Sequel::Model.plugin :nested_attributes
Sequel::Model.plugin :pg_array_associations
Sequel::Model.plugin :tactical_eager_loading
Sequel::Model.plugin :string_stripper

Sequel::Plugins::ValidationHelpers::DEFAULT_OPTIONS.update(
  not_null: {message: "can't be blank"},
  presence: {message: "can't be blank"},
)

module Kvizovi
  module Models
    Base = Sequel::Model
  end
end
