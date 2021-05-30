require "uri"

module Sanemark
  class HTMLRenderer < Renderer
    def initialize(@options = Options.new)
      @output_io = String::Builder.new
      @saved_io = @output_io
      @last_output = "\n"
      @disable_tag = 0
      @in_heading = false
      @plaintext = "" # Keeps track of the text seen while rendering a heading, excluding Sanemark syntax.
    end

    enum DelimiterType
      Bold
      Italics
      Spoiler
    end
    DELIM_TAGS = {
      DelimiterType::Bold => {"strong", nil},
      DelimiterType::Italics => {"em", nil},
      DelimiterType::Spoiler => {"span", {"class" => "spoiler"}},
    }
    NODE_TYPE_TO_DELIM_TYPE = {
      Node::Type::OpenEmphasis => DelimiterType::Italics,
      Node::Type::CloseEmphasis => DelimiterType::Italics,
      Node::Type::OpenStrong => DelimiterType::Bold,
      Node::Type::CloseStrong => DelimiterType::Bold,
      Node::Type::OpenSpoiler => DelimiterType::Spoiler,
      Node::Type::CloseSpoiler => DelimiterType::Spoiler,
    }
    @delim_stack = [] of DelimiterType

    private HEADINGS = %w(h1 h2 h3 h4 h5 h6)

    def heading(node : Node, entering : Bool)
      tag_name = HEADINGS[node.data["level"].as(Int32) - 1]
      if !@options.heading_ids
        if entering
          cr
          tag(tag_name, attrs(node))
        else
          tag(tag_name, end_tag: true)
          cr
        end
      else
        if entering
          # Computing a heading ID requires seeing the entire content of the heading first,
          # so replace our output IO with a buffer that we'll write out when the heading is over.
          @saved_io = @output_io
          @output_io = String::Builder.new
          @in_heading = true
        else
          cr
          @output_io, @saved_io = @saved_io, @output_io
          tag(tag_name, {"id" => Utils.slugify(@plaintext)})
          @output_io << @saved_io.to_s
          @in_heading = false
          @plaintext = ""
          tag(tag_name, end_tag: true)
          cr
        end
      end
    end

    def code(node : Node, entering : Bool)
      tag("code") do
        out(node.text)
      end
    end

    def code_block(node : Node, entering : Bool)
      languages = node.fence_language ? node.fence_language.split : nil
      code_tag_attrs = attrs(node)
      pre_tag_attrs = nil

      if languages && languages.size > 0 && (lang = languages[0]) && !lang.empty?
        code_tag_attrs ||= {} of String => String
        code_tag_attrs["class"] = "language-#{HTML.escape(lang.strip)}"
      end

      cr
      tag("pre", pre_tag_attrs) do
        tag("code", code_tag_attrs) do
          out(node.text)
        end
      end
      cr
    end

    def thematic_break(node : Node, entering : Bool)
      cr
      tag("hr", attrs(node))
      cr
    end

    def block_quote(node : Node, entering : Bool)
      cr
      if entering
        tag("blockquote", attrs(node))
      else
        tag("blockquote", end_tag: true)
      end
      cr
    end

    def list(node : Node, entering : Bool)
      tag_name = node.data["type"] == "bullet" ? "ul" : "ol"

      cr
      if entering
        attrs = attrs(node)

        if (start = node.data["start"].as(Int32)) && start != 1
          attrs ||= {} of String => String
          attrs["start"] = start.to_s
        end

        tag(tag_name, attrs)
      else
        tag(tag_name, end_tag: true)
      end
      cr
    end

    def item(node : Node, entering : Bool)
      if entering
        tag("li", attrs(node))
      else
        tag("li", end_tag: true)
        cr
      end
    end

    def link(node : Node, entering : Bool)
      if entering
        attrs = attrs(node)
        destination = node.data["destination"].as(String)

        if @options.allow_html || !potentially_unsafe(destination)
          attrs ||= {} of String => String
          attrs["href"] = escape(destination)
        end

        tag("a", attrs)

        if !node.first_child?
          out(destination)
        end
      else
        tag("a", end_tag: true)
      end
    end

    def image(node : Node, entering : Bool)
      if entering
        if @disable_tag == 0
          destination = node.data["destination"].as(String)
          if !@options.allow_html && potentially_unsafe(destination)
            lit(%(<img src="" alt=""))
          else
            lit(%(<img src="#{escape(destination)}" alt="))
          end
        end
        @disable_tag += 1
      else
        @disable_tag -= 1
        if @disable_tag == 0
          lit(%(">))
        end
      end
    end

    def html_block(node : Node, entering : Bool)
      if node.text.starts_with? "<nomd>"
        node.text = node.text.lchop("<nomd>").chomp("</nomd>").strip
      end
      cr
      # Doesn't need escaping because the rule isn't used if escaping is on.
      lit(node.text)
      cr
    end

    def html_inline(node : Node, entering : Bool)
      lit(@options.allow_html ? node.text : HTML.escape(node.text))
    end

    def paragraph(node : Node, entering : Bool)
      if (grand_parent = node.parent?.try &.parent?) && grand_parent.type.list?
        return if grand_parent.data["tight"]
      end

      if entering
        cr
        tag("p", attrs(node))
      else
        tag("p", end_tag: true)
        cr
      end
    end

    def open_delim(node : Node)
      delim_type = NODE_TYPE_TO_DELIM_TYPE[node.type]
      @delim_stack << delim_type
      tag(*DELIM_TAGS[delim_type])
    end

    def close_delim(node : Node)
      delim_type = NODE_TYPE_TO_DELIM_TYPE[node.type]
      if @delim_stack[-1] == delim_type
        tag(DELIM_TAGS[delim_type][0], end_tag: true)
        @delim_stack.pop
        # If we're closing one type of delimiter, but there's an unclosed one of another type inside,
        # we need to close and reopen it, because HTML tags can't overlap.
      else
        inner_delim = @delim_stack[-1]
        tag(DELIM_TAGS[inner_delim][0], end_tag: true)
        @delim_stack.pop
        tag(DELIM_TAGS[delim_type][0], end_tag: true)
        @delim_stack.pop
        tag(*DELIM_TAGS[inner_delim])
        @delim_stack << inner_delim
      end
    end

    def soft_break(node : Node, entering : Bool)
      lit("\n")
    end

    def line_break(node : Node, entering : Bool)
      tag("br")
    end

    def text(node : Node, entering : Bool)
      out(node.text)
    end

    private def tag(name : String, attrs = nil, self_closing = false, end_tag = false)
      return if @disable_tag > 0

      @output_io << "<"
      @output_io << "/" if end_tag
      @output_io << name
      attrs.try &.each do |key, value|
        @output_io << ' ' << key << '=' << '"' << value << '"'
      end

      @output_io << ">"
      @last_output = ">"
    end

    private def tag(name : String, attrs = nil)
      tag(name, attrs)
      yield
      tag(name, end_tag: true)
    end

    private def potentially_unsafe(url : String)
      url.match(Rule::UNSAFE_PROTOCOL) && !url.match(Rule::UNSAFE_DATA_PROTOCOL)
    end

    private def attrs(node : Node)
      nil
    end

    def out(string : String)
      @plaintext += string if @in_heading
      lit(escape(string))
    end

    private ESCAPES = {
      '&' => "&amp;",
      '"' => "&quot;",
      '<' => "&lt;",
      '>' => "&gt;",
    }

    def escape(text)
      # If we can determine that the text has no escape chars
      # then we can return the text as is, avoiding an allocation
      # and a lot of processing in `String#gsub`.
      if has_escape_char?(text)
        text.gsub(ESCAPES)
      else
        text
      end
    end

    private def has_escape_char?(text)
      text.each_byte do |byte|
        case byte
        when '&', '"', '<', '>'
          return true
        else
          next
        end
      end
      false
    end
  end
end
