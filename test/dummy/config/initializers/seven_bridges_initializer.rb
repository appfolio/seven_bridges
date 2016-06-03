require 'seven_bridges'
require 'neo4j'

#TODO USE ENV variable
n4j = Neo4j::Session.open(:server_db, 'http://localhost:7474')
n4j.query('match (n) detach delete n')

SevenBridges.configure do |config|
  # change default settings if needed

  #config.klass = MiniTest::Test
  config.project_root = '/Users/scottspeidel/src/github/appfolio/seven_bridges'
end
