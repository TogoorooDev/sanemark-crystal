require "uri"

module Sanemark
  struct Options
    property time, allow_html

    def initialize(
      @time = false,
      @allow_html = false
    )
    end
  end
end
