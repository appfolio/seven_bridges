require 'neo4j'
require 'seven_bridges/method'
require 'seven_bridges/call'
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
                current = get_or_create_current_node(path)
                find_location_and_build_graph(current)
              end
            end
          end
          @trace.enable
        end

        private

        def make_path(tp)
          "#{strip_path(tp.path)}##{tp.method_id}"
        end

        def get_or_create_current_node(path)
          current = Method.find_by(path: path)

          if current.nil? && @callstack.empty?
            current = TestMethod.create(path: path, type: 'test')
          elsif current.nil?
            current = Method.create(path: path, type: 'app')
          end
          current
        end

        def find_location_and_build_graph(current)
          find_parent
          add_calling_relationship current
          create_stack_frame current
        end

        def create_stack_frame(current)
          @callstack << { node: current, level: caller.size }
        end

        def add_calling_relationship(current)
          @callstack.last[:node].calls << current unless @callstack.empty?
          current.called_by << @callstack.first[:node] unless @callstack.empty?
        end

        def find_parent
          return if @callstack.empty?
          while(caller.size <= @callstack.last[:level]) do
            @callstack.pop
            break if @callstack.empty?
          end
        end

        def teardown
          @trace.disable
          @callstack = []
          teardown_without_trace
        end

        def executing_file
          caller.first[/^[^:]+/]
        end

        def strip_path(path)
          path.gsub(SevenBridges.project_root, '')
        end
      end
    end
  end
end
