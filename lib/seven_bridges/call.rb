require 'neo4j'

module SevenBridges
  class Call
    include Neo4j::ActiveRel
    from_class 'SevenBridges::Method'
    to_class   'SevenBridges::Method'

    creates_unique

    type 'calls'
  end
end
