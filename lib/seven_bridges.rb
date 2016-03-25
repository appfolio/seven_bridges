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
              path = "#{strip_path(tp.path)}##{tp.method_id}"
              current = get_or_create_current_node(path)
              previous_callstack_level = @callstack.empty? ? -1 : @callstack.last[:level]
              find_location_and_build_graph(previous_callstack_level, current)
            end
          end
          @trace.enable
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

        def find_location_and_build_graph(previous_callstack_level, current)
          if we_went_deeper?(previous_callstack_level)
            add_calling_relationship current
            create_stack_frame current
          elsif we_climbed_out?(previous_callstack_level)
            climb_to_current
          else # stayed at the same callstack level
            @callstack.pop
            add_calling_relationship current
            create_stack_frame current
          end
        end

        def create_stack_frame(current)
          @callstack << { node: current, level: caller.size - 1 }
        end

        def add_calling_relationship(current)
          @callstack.last[:node].calls << current unless @callstack.empty?
        end

        def we_went_deeper?(previous_callstack_level)
          (caller.size - 1) > previous_callstack_level
        end

        def we_climbed_out?(previous_callstack_level)
          (caller.size - 1) < previous_callstack_level
        end

        def climb_to_current
          while(!we_climbed_out?(@callstack.last[:level])) do
            @callstack.pop
            break if @callstack.length == 0
          end
        end

        def teardown
          @trace.disable
          @callstack = []
          teardown_without_trace
        end

        private

        def clean_call_stack(filter_path = nil)
          stack = caller.reject do |x|
            x =~ /\sin\s.*$/
          end
          stack.select do |x|
            x.start_with? filter_path
          end
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
