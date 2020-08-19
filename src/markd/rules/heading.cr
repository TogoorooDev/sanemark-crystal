module Markd::Rule
  struct Heading
    include Rule

    ATX_HEADING_MARKER    = /^\#{1,6}(?:[ \t]+|$)/

    def match(parser : Parser, container : Node) : MatchValue
      if match = match?(parser, ATX_HEADING_MARKER)
        # ATX Heading matched
        parser.advance_next_nonspace
        parser.advance_offset(match[0].size, false)
        parser.close_unmatched_blocks

        container = parser.add_child(Node::Type::Heading, parser.next_nonspace)
        container.data["level"] = match[0].strip.size
        container.text = parser.line[parser.offset..-1]
          .sub(/^ *#+ *$/, "")
          .sub(/ +#+ *$/, "")

        parser.advance_offset(parser.line.size - parser.offset)

        MatchValue::Leaf
      else
        MatchValue::None
      end
    end

    def token(parser : Parser, container : Node) : Nil
      # do nothing
    end

    def continue(parser : Parser, container : Node) : ContinueStatus
      # a heading can never container > 1 line, so fail to match
      ContinueStatus::Stop
    end

    def can_contain?(type)
      false
    end

    def accepts_lines? : Bool
      false
    end

    private def match?(parser : Parser, regex : Regex) : Regex::MatchData?
      match = parser.line[parser.next_nonspace..-1].match(regex)
      !parser.indented && match ? match : nil
    end
  end
end
