require "uri"

module Sanemark
  struct Options
    property time, allow_html, spoilers, heading_ids

    def initialize(
      @time = false,
      @allow_html = false,
      @spoilers = false,
      @heading_ids = false
    )
    end
  end
end
