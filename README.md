# Insights::Loggers

[![Build Status](https://travis-ci.com/RedHatInsights/insights-loggers-ruby.svg?branch=master)](https://travis-ci.org/RedHatInsights/insights-loggers-ruby)

Loggers and wrapper of [manageiq-loggers](https://github.com/ManageIQ/manageiq-loggers) for Insights ruby projects

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'insights-loggers-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install insights-loggers-ruby

## Usage

### Example
```ruby
require 'insights/loggers'
logger_class = "Insights::Loggers::StdErrorLogger"
logger = Insights::Loggers::Factory.create_logger(logger_class)
logger.class #=> Insights::Loggers::StdErrorLogger
logger.info("test")
#{"@timestamp":"2021-04-28T12:56:28.682015 ","pid":11561,"tid":"3fd1d4c2ffd4","level":"info","message":"test","tags":["insights_application"],"labels":{"app":"insights_application"}}
#^^^standard error output (it is not return value)
#=> true
#
logger = Insights::Loggers::Factory.create_logger(logger_class, {:app_name => "MyApp"})
logger.warn("test")
#{"@timestamp":"2021-04-28T13:31:40.311131 ","pid":11561,"tid":"3fd1d4c2ffd4","level":"warning","message":"test","tags":["MyApp"],"labels":{"app":"MyApp"}}
#^^^standard error output
```
### Logger classes
Currently supported logger classes:
```
ManageIQ::Loggers::Base
ManageIQ::Loggers::Container
ManageIQ::Loggers::CloudWatch
ManageIQ::Loggers::Journald
Insights::Loggers::StdErrorLogger
TopologicalInventory::Providers::Common::Logger
```

First for refers to gem `manageiq-loggers` and
last one refers to `topological_inventory-providers-common` gem.

`insights-loggers-ruby` adds own logger `Insights::Loggers::StdErrorLogger`
which is producing log to standard error output.
This standard error output can be consumed by [haberdasher](https://github.com/RedHatInsights/haberdasher) tool.

### Create logger object

Logger object can be built with method:

```
Insights::Loggers::Factory.create_logger
```
First parameter is `logger_class` and second parameter is
hash with parameters.
Supported hash parameters are:

- `:log_path` - required for `ManageIQ::Loggers::Base` logger, it specifies the path to log file
- `:app_name` - applicable for `Insights::Loggers::StdErrorLogger`, it specifies the tags and labels values in formatted output

### Formatted output for `Insights::Loggers::StdErrorLogger` logger

Standard error logger produces formatted output:

```
{"@timestamp":"2021-04-28T13:31:40.311131 ",
 "hostname": "test.example.com",
 "pid":11561, # process id
 "tid":"3fd1d4c2ffd4", # thread id
 "service": "progname",
 "level":"warning", #info, warning, error, debug
 "message":"test",
 "request_id": "REQ_ID", # Thread.current[:request_id]
 "tags":["MyApp"],
 "labels":{"app":"MyApp"}}
```
- `tags` and `labels` could be set also from `ENV['LOGGER_APP_NAME']`
when app_name is not set in hash parameters.

## Dependencies

Standard error logger inherits from `ManageIQ::Loggers::Container` class and
thanks to that `manageiq-loggers` is required dependency.

Usage other loggers is possible also from `manageiq-loggers` gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ManageIQ/manageiq-loggers.

## License

This project is available as open source under the terms of the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).
