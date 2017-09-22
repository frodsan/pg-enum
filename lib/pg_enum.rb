# frozen_string_literal: true

require "active_support/concern"

module PgEnum
  extend ActiveSupport::Concern

  ENUM_SQL = <<~SQL.squish
    SELECT e.enumlabel
      FROM pg_enum e
      JOIN pg_type t
        ON e.enumtypid = t.oid
     WHERE t.typname = ?
  SQL

  class_methods do
    def pg_enum(attr, options = {})
      return unless table_exists?

      column = columns_hash[attr.to_s]

      if column.nil? || column.type != :enum
        raise "PgEnum: #{ model.table_name }.#{ attr } is not an enum"
      end

      enum(options.merge(column.name.to_sym => enum_values(column)))
    end

    private

    def enum_values(column)
      connection
        .select_all(sanitize_sql_array([ENUM_SQL, column.sql_type]))
        .map { |v| v["enumlabel"] }
        .each_with_object({}) { |v, h| h[v.to_sym] = v }
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
