require "seven_bridges/version"

module SevenBridges
  class << self
    attr_writer :klass, :project_root

    def klass
      @klass || Minitest::Test
    end

    def project_root
      @project_root || '/'
    end

    def setup
      yield self

      klass.class_eval do
        setup do
          @trace = TracePoint.new(:call) do |tp|
            if tp.path =~ /appfolio\/apm_bundle\/apps\/property/
              p "#{self.to_s}: #{strip_path(tp.path)}##{tp.method_id}"
            end
          end
          @trace.enable
        end

        teardown do
          @trace.disable
        end

        private
        def who_am_i
          caller_locations(1,1)[0].label
        end

        def strip_path(path)
          path.gsub(@project_root,'')
        end
      end
    end
  end
end
