require 'csv'
require 'fileutils'

module SevenBridges
  class MemoryStoreCSVDumper

    def initialize(memory_store, base_path)
      @store = memory_store
      @base_path = base_path
    end

    def dump
      FileUtils.mkdir_p(@base_path)

      CSV.open(nodes_header_file, "wb") do |csv|
        csv << ["path:ID", "name", ":LABEL"]
      end

      CSV.open(nodes_file, "wb") do |csv|
        @store.nodes.each do |node|
          csv << [node[:path], node[:name], ((node[:type] == 'app') ? "METHOD" : "TEST_METHOD")]
        end
      end

      CSV.open(edges_header_file, "wb") do |csv|
        csv << [":START_ID", ":END_ID", ":TYPE"]
      end

      CSV.open(edges_file, "wb") do |csv|
        @store.edges.each do |edge|
          csv << [edge[:from], edge[:to], edge[:label]]
        end
      end
    end

    private

    def nodes_header_file
      File.join(@base_path, "nodes_header.csv")
    end

    def nodes_file
      File.join(@base_path, "nodes.csv")
    end

    def edges_header_file
      File.join(@base_path, "relationships_header.csv")
    end

    def edges_file
      File.join(@base_path, "relationships.csv")
    end
  end
end
