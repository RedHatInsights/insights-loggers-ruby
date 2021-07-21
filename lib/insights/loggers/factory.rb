module Insights
  module Loggers
    class Factory
      def self.create_logger(logger_class, args = nil)
        logger_library_loader(logger_class, args)
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

        if args && args[:app_name] && logger.respond_to?(:app_name_for_formatter)
          logger.app_name_for_formatter(args[:app_name])
        end

        if args && args[:extend_module]
          logger.extend(args[:extend_module].safe_constantize)
        end

        logger
      end

      EXTENDED_LIBRARY_FROM_MODULE = {
        "TopologicalInventory::Providers::Common::LoggingFunctions" => "topological_inventory/providers/common/logging"
      }.freeze

      private_class_method def self.logger_library_loader(logger_class, args = nil)
        case logger_class
        when "ManageIQ::Loggers::Base"
          require "manageiq/loggers/base"
        when "ManageIQ::Loggers::Container"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
        when "ManageIQ::Loggers::CloudWatch"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
          require "manageiq/loggers/cloud_watch"
        when "ManageIQ::Loggers::Journald"
          unless RbConfig::CONFIG['host_os'] =~ /linux/i
            raise RuntimeError, "Logger #{logger_class} is not supported for #{RbConfig::CONFIG['host_os']}"
          end

          require "manageiq/loggers/base"
          require "manageiq/loggers/journald"
        when "Insights::Loggers::StdErrorLogger"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
          require "insights/loggers/container"
          require "insights/loggers/std_error_logger"
          if args && args[:extend_module]
            library_path = EXTENDED_LIBRARY_FROM_MODULE[args[:extend_module]]
            raise ArgumentError, "Unable to find library for #{args[:extend_module]}" unless library_path

            require EXTENDED_LIBRARY_FROM_MODULE[args[:extend_module]]
          end
        when "Insights::Loggers::CloudWatch"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
          require "insights/loggers/container"
          require "insights/loggers/cloud_watch"
        when "TopologicalInventory::Providers::Common::Logger"
          require "topological_inventory/providers/common/logging"
        when "Insights::Loggers::Container"
          require "manageiq/loggers/base"
          require "manageiq/loggers/container"
          require "insights/loggers/container"
        else
          raise ArgumentError, "Can't load libraries for #{logger_class}."
        end
      end
    end
  end
end
