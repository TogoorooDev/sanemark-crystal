require "uri"

module Sanemark
  struct Options
    property time, allow_html, spoilers

    def initialize(
      @time = false,
      @allow_html = false,
      @spoilers = false
    )
    end
  end
end
