module Sanemark::Rule
  struct ThematicBreak
    include Rule

    def match(parser : Parser, container : Node) : MatchValue
      if !parser.indented && parser.line[parser.offset..].match(THEMATIC_BREAK)
        parser.close_unmatched_blocks
        parser.add_child(Node::Type::ThematicBreak, parser.next_nonspace)
        parser.advance_offset(parser.line.size - parser.offset, false)
        MatchValue::Leaf
      else
        MatchValue::None
      end
    end

    def continue(parser : Parser, container : Node) : ContinueStatus
      # a thematic break can never container > 1 line, so fail to match:
      ContinueStatus::Stop
    end

    def token(parser : Parser, container : Node) : Nil
      # do nothing
    end

    def can_contain?(type)
      false
    end

    def accepts_lines? : Bool
      false
    end
  end
end
