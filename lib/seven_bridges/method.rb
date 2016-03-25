require 'neo4j'

module SevenBridges
  class Method
    include Neo4j::ActiveNode
    #self.mapped_label_name = 'Method'
    property :path
    property :type
    # property :num_incoming_refs, type: Integer, default: 0

    validates :path, presence: true
    validates :type, presence: true
    #validates :num_incoming_refs, numericality: { only_integer: true }
    has_many :out, :calls , rel_class: 'SevenBridges::Call', model_class: 'SevenBridges::Method'
    #has_many :in, :called_by, rel_class: :Call, model_class: :Method

  end
end
