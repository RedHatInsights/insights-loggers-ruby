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
      Insights::Loggers::LoggingService
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
          logger = described_class.create_logger(logger_klass, arguments)
          expect(logger).to be_a(logger_klass.safe_constantize)
        end
      end
    end
  end
end
