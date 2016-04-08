require 'neo4j'
require 'seven_bridges/method'
require 'seven_bridges/call'
require 'seven_bridges/called_by'
require 'seven_bridges/test_method'
require 'seven_bridges/neo4j_store'
require 'seven_bridges/memory_store'
require 'seven_bridges/memory_store_csv_dumper'

module SevenBridges
  class << self
    attr_writer :klass, :project_root, :store

    def klass
      @klass ||= Minitest::Test
    end

    def project_root
      @project_root ||= ''
    end

    def store
      @store ||= SevenBridges::Neo4jStore.new
    end

    def configure
      yield self

      klass.class_eval do
        alias_method :setup_without_trace, :setup
        alias_method :teardown_without_trace, :teardown

        def setup
          setup_without_trace
          @callstack = []
          @trace = TracePoint.new(:call) do |tp|
            if tp.path.start_with? SevenBridges.project_root
              path = make_path(tp)
              if !path.end_with?('#teardown')
                find_location_and_build_graph path
              end
            end
          end
          @trace.enable
        end

        private

        def make_path(tp)
          "#{strip_project_root(tp.path)}##{tp.method_id}"
        end

        def get_or_create_current_node(path)
          current = store.find_method(path)
          return current if current.present?

          return store.create_test_method_node(get_method_name(path), path) if @callstack.empty?
          return store.create_method_node(get_method_name(path), path)
        end

        def find_location_and_build_graph(path)
          find_parent
          current = get_or_create_current_node(path)
          add_calling_relationship current
          create_stack_frame current
        end

        def create_stack_frame(current)
          @callstack << { node: current, level: caller.size }
        end

        def add_calling_relationship(current)
          return if @callstack.empty?

          store.add_relationship(:calls, @callstack.last[:node], current)
          store.add_relationship(:called_by, current, @callstack.first[:node])
        end

        def find_parent
          while(!@callstack.empty? && caller.size <= @callstack.last[:level]) do
            @callstack.pop
          end
        end

        def teardown
          @trace.disable
          @callstack = []
          teardown_without_trace
        end

        def get_method_name(path)
          path.split('#')[1]
        end

        def strip_project_root(path)
          path[SevenBridges.project_root.length..-1]
        end
      end
    end
  end
end
