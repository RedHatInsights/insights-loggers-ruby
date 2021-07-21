require 'manageiq/loggers/base'
require 'manageiq/loggers/container'
require 'insights/loggers/container'
require 'insights/loggers/std_error_logger'
require 'timecop'

describe Insights::Loggers::StdErrorLogger do
  let(:log_message) { "some message" }
  let(:time)        { Time.now }

  before do
    Timecop.freeze(time)
  end

  let(:default_logger_app_name) { "insights_application" }

  def expected_hash(time, message, request_id = nil)
    {
      "@timestamp" => time,
      "hostname"   => ENV["HOSTNAME"],
      "pid"        => $PROCESS_ID,
      "tid"        => Thread.current.object_id.to_s(16),
      "level"      => "info",
      "message"    => message,
      "request_id" => request_id,
      "tags"       => [default_logger_app_name],
      "labels"     => {"app" => default_logger_app_name}
    }.compact
  end

  describe "with a request_id in thread local storage" do
    let(:request_id) { "123" }

    context "in :request_id" do
      before { Thread.current[:request_id] = request_id }
      after  { Thread.current[:request_id] = nil }

      it "logs a message" do
        time_formatted = time.strftime("%Y-%m-%dT%H:%M:%S.%6N ".freeze)
        logger = described_class.new
        expected_output  = JSON.generate(expected_hash(time_formatted, log_message, request_id)) << "\n"
        expect { logger.info(log_message) }.to output(expected_output).to_stderr_from_any_process
      end
    end

    context "without default app_name" do
      let(:logger_app_name)         { "sources-api" }
      let(:default_logger_app_name) { logger_app_name }

      it "logs a message when app_name is passed to logger" do
        time_formatted = time.strftime("%Y-%m-%dT%H:%M:%S.%6N ".freeze)
        logger = described_class.new
        logger.app_name_for_formatter(logger_app_name)

        expected_output  = JSON.generate(expected_hash(time_formatted, log_message)) << "\n"
        expect { logger.info(log_message) }.to output(expected_output).to_stderr_from_any_process
      end

      context "app_name is present in ENV variable" do
        before do
          ENV["LOGGER_APP_NAME"] = logger_app_name
        end

        it "logs a message" do
          time_formatted = time.strftime("%Y-%m-%dT%H:%M:%S.%6N ".freeze)
          logger = described_class.new
          expected_output  = JSON.generate(expected_hash(time_formatted, log_message)) << "\n"
          expect { logger.info(log_message) }.to output(expected_output).to_stderr_from_any_process
        end

        after do
          ENV["LOGGER_APP_NAME"] = nil
        end
      end

    end
  end

  it "logs a message" do
    time_formatted = time.strftime("%Y-%m-%dT%H:%M:%S.%6N ".freeze)
    logger = described_class.new

    expected_output  = JSON.generate(expected_hash(time_formatted, log_message)) << "\n"
    expect { logger.info(log_message) }.to output(expected_output).to_stderr_from_any_process
  end

  after do
    Timecop.return
  end
end
