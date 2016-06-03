# SevenBridges


## Installation

Add seven_bridges to Gemfile
```ruby
gem 'seven_bridges'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seven_bridges

## Usage

Add an initializer to your project in e.g. /my-sweet-app/config/initializers/seven_bridges_initializer.rb with:

```ruby
require 'seven_bridges'
require 'neo4j'

# TODO USE ENV variable
n4j = Neo4j::Session.open(:server_db, 'http://localhost:7474') 
n4j.query('match (n) detach delete n')

SevenBridges.configure do |config|
  # change default settings if needed

  # config.klass = MiniTest::Test
  config.project_root = '/path/to/src/my/project/my-sweet-app'
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

