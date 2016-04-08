module SevenBridges
  class Neo4jStore

    def find_method(path)
       Method.find_by(path: path)
    end

    def create_test_method_node(method_name, path)
      TestMethod.create(name: method_name, path: path, type: 'test')
    end

    def create_method_node(method_name, path)
      Method.create(name: method_name, path: path, type: 'app')
    end

    def add_relationship(label, from, to)
      from.public_send(label) << to
    end
  end
end
