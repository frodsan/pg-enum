# frozen_string_literal: true

require "active_support/concern"
require "active_support/lazy_load_hooks"
require "rails/railtie"

module PgEnum
  extend ActiveSupport::Concern

  ENUM_SQL = <<~SQL.squish
    SELECT t.typname AS name, e.enumlabel AS value
      FROM pg_enum e
      JOIN pg_type t
        ON e.enumtypid = t.oid
  SQL

  mattr_accessor :enums_hash

  def self.load_enums_hash(connection)
    self.enums_hash = enum_rows(connection).each_with_object({}) do |row, hash|
      hash.deep_merge!(row["name"] => { row["value"].to_sym => row["value"] })
    end
  end

  def self.enum_rows(connection)
    connection.select_all(ENUM_SQL)
  end

  class Railtie < Rails::Railtie
    initializer "pg-enum.enums", after: "active_record.initialize_database" do
      ActiveSupport.on_load(:active_record) do
        PgEnum.load_enums_hash(connection)
      end
    end
  end

  class_methods do
    def pg_enum(attr, options = {})
      return unless table_exists?

      column = columns_hash[attr.to_s]

      if column.nil? || column.type != :enum
        raise "PgEnum: #{ model.table_name }.#{ attr } is not an enum"
      end

      enum(options.merge(column.name.to_sym => PgEnum.enums_hash[column.sql_type]))
    end
  end

  module MigrationHelpers
    def create_enum(name, values)
      values = values.map { |v| "'#{ v }'" }

      execute "CREATE TYPE #{ name } AS ENUM (#{ values.join(', ') })"
    end

    def drop_enum(name)
      execute "DROP TYPE #{ name }"
    end
  end
end
