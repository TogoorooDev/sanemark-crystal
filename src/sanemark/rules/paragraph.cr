module Sanemark::Rule
  struct Paragraph
    include Rule

    def match(parser : Parser, container : Node) : MatchValue
      MatchValue::None
    end

    def continue(parser : Parser, container : Node) : ContinueStatus
      return ContinueStatus::Stop if parser.line.match(HTML_BLOCK_OPEN[-1])
      parser.blank ? ContinueStatus::Stop : ContinueStatus::Continue
    end

    def token(parser : Parser, container : Node) : Nil
    end

    def can_contain?(type)
      false
    end

    def accepts_lines? : Bool
      true
    end
  end
end
