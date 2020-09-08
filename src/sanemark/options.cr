require "uri"

module Sanemark
  struct Options
    property time, gfm, toc, source_pos, allow_html

    def initialize(
      @time = false,
      @gfm = false,
      @toc = false,
      @source_pos = false,
      @allow_html = false
    )
    end
  end
end
