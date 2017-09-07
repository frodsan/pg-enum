# frozen_string_literal: true

require "bundler/setup"
require "active_record"
require "pg"
require "minitest/autorun"
require_relative "../lib/pg_enum"

configuration = {
  "adapter"  => "postgresql",
  "database" => "pg_enum",
  "host" => "localhost",
  "port" => 5432
}

ActiveRecord::Base.establish_connection(configuration.merge(
  "database" => "postgres",
  "schema_search_path" => "public"
))

ActiveRecord::Base.connection.drop_database(configuration["database"])

ActiveRecord::Base.connection.create_database(configuration["database"])

ActiveRecord::Base.establish_connection(configuration)

ActiveRecord::Schema.define do
  execute "CREATE TYPE conversation_status AS ENUM ('active', 'archived')"

  create_table :conversations, force: true do |t|
    t.column :status, :conversation_status, default: "active"
  end
end

class Conversation < ActiveRecord::Base
  include PgEnum

  pg_enum :status
end

class PgEnumTest < Minitest::Test
  def setup
    Conversation.delete_all
  end

  def test_default
    assert_equal "active", Conversation.new.status
  end

  def test_enum_values
    assert_equal "active", Conversation.statuses[:active]
    assert_equal "archived", Conversation.statuses[:archived]
  end

  def test_scopes
    conversation = Conversation.create!

    assert_equal 1, Conversation.active.count
    assert_equal 0, Conversation.archived.count

    conversation = Conversation.create!(status: "archived")

    assert_equal 1, Conversation.archived.count
  end

  def test_predicates
    assert Conversation.new.active?
    refute Conversation.new.archived?
  end

  def test_writter
    conversation = Conversation.create!

    assert_equal "active", conversation.status

    conversation.archived!

    assert_equal "archived", conversation.status
  end
end
