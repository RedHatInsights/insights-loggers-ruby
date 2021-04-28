require 'pry-nav'

module Insights
  module Loggers
    class Base
      def self.create_logger(logger_class, args = nil)
        logger_library_loader(logger_class)
        klass = logger_class.safe_constantize

        if klass
          logger_builder(klass, args)
        else
          raise ArgumentError, "Unable to load logger class #{logger_class}"
        end
      end

      private_class_method def self.logger_builder(klass, args)
        logger = if args.is_a?(Hash) && args[:log_path]
                   klass.new(args[:log_path]) # for ManageIQ::Loggers::Base
                 else
                   klass.new
                 end
        logger.app_name_for_formatter(args[:app_name]) if args && args[:app_name]
        logger
      end

      private_class_method def self.logger_library_loader(logger_class)
        case logger_class
        when "ManageIQ::Loggers::Base"
          require "manageiq/loggers/base"
        when "ManageIQ::Loggers::Container"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
        when "ManageIQ::Loggers::CloudWatch"
          require "manageiq/loggers/base"
          require "manageiq/loggers/cloud_watch"
        when "ManageIQ::Loggers::Journald"
          unless RbConfig::CONFIG['host_os'] =~ /linux/i
            raise RuntimeError, "Logger #{logger_class} is not supported for #{RbConfig::CONFIG['host_os']}"
          end

          require "manageiq/loggers/base"
          require "manageiq/loggers/journald"
        when "Insights::Loggers::LoggingService"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
          require "insights/loggers/logging_service"
        when "TopologicalInventory::Providers::Common::Logger"
          require "topological_inventory/providers/common/logging"
        else
          raise ArgumentError, "Can't load libraries for #{logger_class}."
        end
      end
    end
  end
end
