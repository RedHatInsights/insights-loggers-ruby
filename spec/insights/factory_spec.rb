require 'cloudwatchlogger'
require 'insights/loggers/factory'

describe Insights::Loggers::Factory do
  before do
    ENV["CW_AWS_ACCESS_KEY_ID"] = "test"
    ENV["CW_AWS_SECRET_ACCESS_KEY"] = "test"
    ENV["CLOUD_WATCH_LOG_GROUP"] = "test"
    ENV["HOSTNAME"] = "test"
    allow(CloudWatchLogger::Client::AWS_SDK::DeliveryThreadManager).to receive(:new)
  end

  describe '.create_logger' do
    LOGGER_CLASSES = %w[
      ManageIQ::Loggers::Base
      ManageIQ::Loggers::Container
      ManageIQ::Loggers::CloudWatch
      ManageIQ::Loggers::Journald
      Insights::Loggers::StdErrorLogger
      Insights::Loggers::CloudWatch
      Insights::Loggers::Container
      TopologicalInventory::Providers::Common::Logger
    ].freeze

    LOGGER_CLASSES.each do |logger_klass|
      it "creates logger object for class #{logger_klass}" do
        arguments = {}
        arguments[:log_path] = "test" if logger_klass == "ManageIQ::Loggers::Base"

        if logger_klass == "ManageIQ::Loggers::Journald" && RbConfig::CONFIG['host_os'] !~ /linux/i
          expect do
            described_class.create_logger(logger_klass, arguments)
          end.to raise_error(RuntimeError)
        else
          if logger_klass == "Insights::Loggers::CloudWatch"
            ENV["CONTAINER_LOG_LEVEL"] = "info"
            ENV["LOG_LEVEL"] = "info"
          end

          logger = described_class.create_logger(logger_klass, arguments)

          if logger_klass == "Insights::Loggers::CloudWatch"
            expect { logger.debug("test") }.not_to output.to_stdout_from_any_process
            ENV["CONTAINER_LOG_LEVEL"] = nil
            ENV["LOG_LEVEL"] = nil
          end

          expect(logger).to be_a(logger_klass.safe_constantize)
        end
      end
    end

    it "loads logging methods from extended module" do
      logger_class = "Insights::Loggers::StdErrorLogger"
      logger = Insights::Loggers::Factory.create_logger(logger_class, :extend_module => "TopologicalInventory::Providers::Common::LoggingFunctions")
      expect(logger).to respond_to(:availability_check)
    end
  end
end
