require 'test_helper'

class MemoryStoreTest < Minitest::Test

  def setup
    @store = SevenBridges::MemoryStore.new
  end

  def test_find_method
    @store.create_method_node("michael", "/blah/null")

    expected = {name: "michael", path: "/blah/null", type: 'app'}
    assert_equal expected, @store.find_method("/blah/null")
  end

  def test_create_test_method_node
    @store.create_test_method_node("michael", "/blah/null")

    expected = {
      "/blah/null" => {name: "michael", path: "/blah/null", type: 'test'}
    }
    assert_equal expected, @store.nodes
  end

  def test_create_method_node
    @store.create_method_node("michael", "/blah/null")

    expected = {
      "/blah/null" => {name: "michael", path: "/blah/null", type: 'app'}
    }
    assert_equal expected, @store.nodes
  end

  def test_add_relationship
    node1 = @store.create_method_node("michael", "/blah/null")
    node2 = @store.create_method_node("michael", "/hey/null")

    @store.add_relationship("pokemon", node1, node2)

    expected = [
      {label: "pokemon", from: node1[:path], to: node2[:path]}
    ]
    assert_equal expected, @store.edges
  end

  def test_add_relationship__duplicates_are_ignored
    node1 = @store.create_method_node("michael", "/blah/null")
    node2 = @store.create_method_node("michael", "/hey/null")

    @store.add_relationship("pokemon", node1, node2)
    @store.add_relationship("pokemon", node1, node2)

    expected = [
      {label: "pokemon", from: node1[:path], to: node2[:path]}
    ]
    assert_equal expected, @store.edges
  end
end
