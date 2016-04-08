require 'test_helper'

class MemoryStoreCSVDumperTest < Minitest::Test

  def setup
    super

    @store  = SevenBridges::MemoryStore.new

    @base_path = Dir.tmpdir
    @dumper = SevenBridges::MemoryStoreCSVDumper.new(@store, @base_path)
  end

  def test_dump
    node1 = @store.create_method_node("michael", "/blah/null#michael")
    node2 = @store.create_method_node("michael", "/hey/null#michael")
    node3 = @store.create_method_node("jewell", "/hey/null#jewell")

    @store.add_relationship(:calls, node1, node2)
    @store.add_relationship(:called_by, node1, node2)
    @store.add_relationship(:pokemon, node3, node1)

    @dumper.dump

    assert_file_exists "nodes_header.csv"
    assert_file_exists "nodes.csv"
    assert_file_exists "relationships_header.csv"
    assert_file_exists "relationships.csv"

    assert_file_contents "nodes_header.csv", <<-CSV.strip_heredoc
      path:ID,name,:LABEL
    CSV

    assert_file_contents "nodes.csv", <<-CSV.strip_heredoc
      /blah/null#michael,michael,METHOD
      /hey/null#michael,michael,METHOD
      /hey/null#jewell,jewell,METHOD
    CSV

    assert_file_contents "relationships_header.csv", <<-CSV.strip_heredoc
      :START_ID,:END_ID,:LABEL
    CSV

    assert_file_contents "relationships.csv", <<-CSV.strip_heredoc
      /blah/null#michael,/hey/null#michael,calls
      /blah/null#michael,/hey/null#michael,called_by
      /hey/null#jewell,/blah/null#michael,pokemon
    CSV
  end

  private

  def assert_file_contents(file_name, contents)
    assert_equal contents, File.read(File.join(@base_path, file_name))
  end

  def assert_file_exists(file_name)
    assert File.exist?(File.join(@base_path, file_name)), "Expected #{file_name} to exist."
  end
end
