module Insights
  module Loggers
    class StdErrorLogger < ManageIQ::Loggers::Container
      def initialize(*args)
        super
        self.reopen(STDERR)
        self.formatter = Formatter.new
      end

      def app_name_for_formatter(app_name)
        self.formatter.logger_app_name = app_name
      end

      class Formatter < ManageIQ::Loggers::Container::Formatter
        attr_reader :logger_app_name
        attr_writer :logger_app_name

        def call(severity, time, progname, msg)
          payload = {
            :@timestamp    => format_datetime(time),
            :hostname      => hostname,
            :pid           => $PROCESS_ID,
            :tid           => thread_id,
            :service       => progname,
            :level         => translate_error(severity),
            :message       => prefix_task_id(msg2str(msg)),
            :request_id    => request_id,
            :tags          => [app_name],
            :labels        => {"app" => app_name}
          }.compact

          JSON.generate(payload) << "\n"
        end

        def app_name
          logger_app_name || ENV['LOGGER_APP_NAME'] || "insights_application"
        end
      end
    end
  end
end
