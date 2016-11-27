# Load the Rails application.
require_relative 'application'

class Logger::MyFormatFormatter < Logger::Formatter
  cattr_accessor(:datetime_format) { "%Y/%m/%d %H:%m:%S" }

  def call(severity, timestamp, progname, msg)
    "[#{timestamp.strftime(datetime_format)}] #{severity[0..2]}: #{String === msg ? msg : msg.inspect}\n"
  end
end

# Initialize the Rails application.
Rails.application.initialize!
