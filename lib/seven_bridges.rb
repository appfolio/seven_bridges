require 'neo4j'
require 'seven_bridges/method'
require 'seven_bridges/call'
require 'seven_bridges/called_by'
require 'seven_bridges/test_method'

module SevenBridges
  class << self
    attr_writer :klass, :project_root

    def klass
      @klass ||= Minitest::Test
    end

    def project_root
      @project_root ||= ''
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
          current = Method.find_by(path: path)
          return current if current.present?

          return TestMethod.create(name: get_method_name(path), path: path, type: 'test') if @callstack.empty?

          return Method.create(name: get_method_name(path), path: path, type: 'app')
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

          @callstack.last[:node].calls << current
          current.called_by << @callstack.first[:node]
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
