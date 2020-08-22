module Sanemark
  module Rule
    ESCAPABLE_STRING    = %Q([!"#$%&'()*+,./:;<=>?@[\\\\\\]^_`{|}~-])
    ESCAPED_CHAR_STRING = %Q(\\\\) + ESCAPABLE_STRING

    TAG_NAME_STRING             = %Q([A-Za-z][A-Za-z0-9-]*)
    ATTRIBUTE_NAME_STRING       = %Q([a-zA-Z_:][a-zA-Z0-9:._-]*)
    UNQUOTED_VALUE_STRING       = %Q([^"'=<>`\\x00-\\x20]+)
    SINGLE_QUOTED_VALUE_STRING  = %Q('[^']*')
    DOUBLE_QUOTED_VALUE_STRING  = %Q("[^"]*")
    ATTRIBUTE_VALUE_STRING      = "(?:" + UNQUOTED_VALUE_STRING + "|" + SINGLE_QUOTED_VALUE_STRING + "|" + DOUBLE_QUOTED_VALUE_STRING + ")"
    ATTRIBUTE_VALUE_SPEC_STRING = "(?:" + "\\s*=" + "\\s*" + ATTRIBUTE_VALUE_STRING + ")"
    ATTRIBUTE                   = "(?:" + "\\s+" + ATTRIBUTE_NAME_STRING + ATTRIBUTE_VALUE_SPEC_STRING + "?)"

    MAYBE_SPECIAL  = {'#', '`', '~', '*', '+', '_', '=', '<', '>', '-'}
    THEMATIC_BREAK = /^(\*{3,}|-{3,})$/

    ESCAPABLE = /^#{ESCAPABLE_STRING}/

    TICKS = /`+/

    OPEN_TAG  = "<" + TAG_NAME_STRING + ATTRIBUTE + "*" + "\\s*/?>"
    CLOSE_TAG = "</" + TAG_NAME_STRING + "\\s*[>]"

    OPEN_TAG_STRING               = "<#{TAG_NAME_STRING}#{ATTRIBUTE}*" + "\\s*/?>"
    CLOSE_TAG_STRING              = "</#{TAG_NAME_STRING}\\s*[>]"
    COMMENT_STRING                = "<!---->|<!--(?:-?[^>-])(?:-?[^-])*-->"
    DECLARATION_STRING            = "<![A-Z]+" + "\\s+[^>]*>"
    HTML_TAG_STRING               = "(?:#{OPEN_TAG_STRING}|#{CLOSE_TAG_STRING}|#{COMMENT_STRING}|#{DECLARATION_STRING})"
    HTML_TAG                      = /^#{HTML_TAG_STRING}/i

    HTML_BLOCK_OPEN = [
      /^<script(?:\s|>|$)/i,
      /^<style(?:\s|>|$)/i,
      /^<pre(?:\s|>|$)/i,
      /^<!--/,
      /^<nomd>/,
      /^<![A-Z]/,
      Regex.new("^(?:" + OPEN_TAG + "|" + CLOSE_TAG + ")\\s*$", Regex::Options::IGNORE_CASE),
    ]

    HTML_BLOCK_CLOSE = [
      /<\/script>/i,
      /<\/style>/i,
      /<\/pre>/i,
      /-->/,
      /^<\/nomd>/,
    ]

    LINK_TITLE = Regex.new("^(?:\"(#{ESCAPED_CHAR_STRING}|[^\"\\x00])*\"" +
                           "|'(#{ESCAPED_CHAR_STRING}|[^'\\x00])*'" +
                           "|\\((#{ESCAPED_CHAR_STRING}|[^)\\x00])*\\))")

    LINK_LABEL = Regex.new("^\\[(?:[^\\\\\\[\\]]|" + ESCAPED_CHAR_STRING + "|\\\\){0,}\\]")

    PUNCTUATION          = /\p{P}/
    UNSAFE_PROTOCOL      = /^javascript:|vbscript:|file:|data:/i
    UNSAFE_DATA_PROTOCOL = /^data:image\/(?:png|gif|jpeg|webp)/i

    CODE_INDENT = 4

    # Match Value
    #
    # - None: no match
    # - Container: match container, keep going
    # - Leaf: match leaf, no more block starts
    enum MatchValue
      None
      Container
      Leaf
    end

    # match and parse
    abstract def match(parser : Parser, container : Node) : MatchValue

    # token finalize
    abstract def token(parser : Parser, container : Node) : Nil

    # continue
    abstract def continue(parser : Parser, container : Node) : ContinueStatus

    enum ContinueStatus
      Continue
      Stop
      Return
    end

    # accepts_line
    abstract def accepts_lines? : Bool

    private def space_or_tab?(char : Char?) : Bool
      char == ' ' || char == '\t'
    end
  end
end

require "./rules/*"
