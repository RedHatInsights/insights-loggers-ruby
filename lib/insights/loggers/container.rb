require 'active_support/core_ext/string'
require 'active_support/logger'

module Insights
  module Loggers
    class Container < ManageIQ::Loggers::Container
      def initialize(logdev = STDOUT, *args)
        super
        self.level = ENV['CONTAINER_LOG_LEVEL'] || ENV['LOG_LEVEL'] || DEBUG
      end

      def level=(new_level)
        # overwrite method ManageIQ::Loggers::Container#level=
        method(__method__).super_method.super_method.call(new_level)
      end
    end
  end
end
