module Sanemark::Rule
  struct Heading
    include Rule

    HEADING_MARKER = /^\#{1,6} /

    def match(parser : Parser, container : Node) : MatchValue
      if match = match?(parser, HEADING_MARKER)
        parser.advance_next_nonspace
        parser.advance_offset(match[0].size, false)
        parser.close_unmatched_blocks

        container = parser.add_child(Node::Type::Heading, parser.next_nonspace)
        container.data["level"] = match[0].strip.size
        container.text = parser.line[parser.offset..]
          .sub(/^ *#+ *$/, "")

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
      # a heading can never contain > 1 line, so fail to match
      ContinueStatus::Stop
    end

    def can_contain?(type)
      false
    end

    def accepts_lines? : Bool
      false
    end

    private def match?(parser : Parser, regex : Regex) : Regex::MatchData?
      parser.line[parser.offset..].match(regex)
    end
  end
end
