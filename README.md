# PgEnum

Add support for Postgres (enum)erated types to Active Record

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg-enum'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg-enum

## Usage

Create an enum type like:

```ruby
# db/migrate/20170818114925_add_status_to_conversations.rb
class AddStatusToConversations < ActiveRecord::Migration[5.1]
  include PgEnum::MigrationHelpers

  def up
    create_enum :conversation_status, [:active, :archived]
    add_column :conversations, :status, :conversation_status, default: "created"
  end

  def down
    remove_column :conversations, :status
    drop_enum :conversation_status
  end
end
```

To add PgEnum to an Active Record model, simply include the `PgEnum` module.

```ruby
class Conversation < ActiveRecord::Base
  include PgEnum

  pg_enum :status
end
```

The API is the same as [ActiveRecord::Enum](http://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
Conversation.statuses
# => { active: 'active', archived: 'archived' }

conversation = Conversation.create
conversation.status   # => "created"
conversation.created? # => true

conversation.archived!
conversation.status    # => "archived"
conversation.archived? # => true

Conversation.active.count   # => 0
Conversation.archived.count # => 1
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
