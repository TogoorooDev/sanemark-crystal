require "json"

module Markd
  module Utils
    def self.timer(label : String, measure_time? : Bool)
      return yield unless measure_time?

      start_time = Time.utc
      yield

      puts "#{label}: #{(Time.utc - start_time).total_milliseconds}ms"
    end

    DECODE_ENTITIES_REGEX = Regex.new("\\\\" + Rule::ESCAPABLE_STRING, Regex::Options::IGNORE_CASE)
  end
end
