require 'neo4j'

module SevenBridges
  class CalledBy
    include Neo4j::ActiveRel
    from_class 'SevenBridges::Method'
    to_class   'SevenBridges::Method'

    creates_unique

    type 'called_by'
  end
end
