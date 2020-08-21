require "json"

module Sanemark
  module Utils
    def self.timer(label : String, measure_time? : Bool)
      return yield unless measure_time?

      start_time = Time.utc
      yield

      puts "#{label}: #{(Time.utc - start_time).total_milliseconds}ms"
    end

    ESCAPE_REGEX = Regex.new("\\\\" + Rule::ESCAPABLE_STRING, Regex::Options::IGNORE_CASE)

    def self.escape(text : String) : String
      text.gsub(ESCAPE_REGEX) { |text| text[1].to_s }
    end
  end
end
