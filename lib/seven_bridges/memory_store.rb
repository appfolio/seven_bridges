module SevenBridges
  class MemoryStore
    attr_reader :nodes

    def initialize
      @nodes = {}
      @edges = {}
    end

    def edges
      @edges.keys
    end

    def find_method(path)
      @nodes[path]
    end

    def create_test_method_node(method_name, path)
      @nodes[path] ||= {name: method_name, path: path, type: 'test'}
    end

    def create_method_node(method_name, path)
      @nodes[path] ||= {name: method_name, path: path, type: 'app'}
    end

    def add_relationship(label, from, to)
      @edges[{label: label, from: from[:path], to: to[:path]}] = 1
    end
  end
end
