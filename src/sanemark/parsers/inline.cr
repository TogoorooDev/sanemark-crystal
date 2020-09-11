require "html"

module Sanemark::Parser
  class Inline
    include Parser

    private getter! brackets

    def initialize(@options : Options)
      @text = ""
      @pos = 0
      @delimiters = [] of Delimiter
    end

    def parse(node : Node)
      @pos = 0
      @text = node.text.chomp("\n")
      @delimiters.clear

      while true
        break unless process_line(node)
      end

      node.text = ""
      process_emphasis(nil)
    end

    private def process_line(node : Node)
      char = char_at?(@pos)

      return false unless char && char != Char::ZERO
      res = case char
            when '\n'
              newline(node)
            when '\\'
              backslash(node)
            when '`'
              backtick(node)
            when '*'
              delim(char, node)
            when '['
              open_bracket(node)
            when '!'
              bang(node)
            when ']'
              close_bracket(node)
            when '<'
              html_tag(node)
            else
              string(node)
            end

      unless res
        @pos += 1
        node.append_child(text(char))
      end

      true
    end

    private def newline(node : Node)
      @pos += 1 # assume we're at a \n
      node.append_child(Node.new(Node::Type::SoftBreak))
      true
    end

    private def backslash(node : Node)
      @pos += 1

      char = @pos < @text.bytesize ? char_at(@pos).to_s : nil
      child = if char_at?(@pos) == '\n'
                @pos += 1
                Node.new(Node::Type::LineBreak)
              elsif char && char.match(Rule::ESCAPABLE)
                c = text(char)
                @pos += 1
                c
              else
                text("\\")
              end

      node.append_child(child)

      true
    end

    private def backtick(node : Node)
      start_pos = @pos
      contents = ""
      loop do
        @pos += 1
        case char_at?(@pos)
        when nil
          @pos = start_pos
          return false
        when '\\'
          nextchar = char_at?(@pos + 1)
          if {'\\', '`'}.includes? nextchar
            contents += nextchar.as Char
            @pos += 1
          else
            contents += '\\'
          end
        when '`'
          @pos += 1
          # No empty code spans.
          if contents.size == 0
            node.append_child(text "``")
            return true
          end
          break
        else
          contents += char_at?(@pos).as Char
        end
      end
      child = Node.new(Node::Type::Code)
      child.text = contents
      node.append_child(child)
      true
    end

    private def bang(node : Node)
      start_pos = @pos
      @pos += 1
      if char_at?(@pos) == '['
        @pos += 1
        child = text("![")
        node.append_child(child)

        add_bracket(child, start_pos + 1, true)
      else
        node.append_child(text("!"))
      end

      true
    end

    private def add_bracket(node : Node, index : Int32, image = false)
      brackets.bracket_after = true if brackets?
      @brackets = Bracket.new(node, @brackets, [] of Delimiter, index, image, true)
    end

    private def remove_bracket
      @brackets = brackets.previous?
    end

    private def open_bracket(node : Node)
      start_pos = @pos
      @pos += 1

      child = text("[")
      node.append_child(child)

      add_bracket(child, start_pos, false)

      true
    end

    private def close_bracket(node : Node)
      dest = ""
      matched = false
      @pos += 1
      start_pos = @pos

      # get last [ or ![
      opener = @brackets
      unless opener
        # no matched opener, just return a literal
        node.append_child(text("]"))
        return true
      end
      unless opener.active
        # no matched opener, just return a literal
        node.append_child(text("]"))
        process_emphasis(opener.delimiters)
        # take opener off brackets stack
        remove_bracket
        return true
      end

      # If we got here, open is a potential opener
      is_image = opener.image

      # Check to see if we have a link/image
      save_pos = @pos

      # Inline link?
      if char_at?(@pos) == '('
        @pos += 1
        dest = link_destination
        if (dest != "") && char_at?(@pos) == ')'
          @pos += 1
          matched = true
        else
          @pos = save_pos
        end
      end

      if matched
        child = Node.new(is_image ? Node::Type::Image : Node::Type::Link)
        child.data["destination"] = dest

        tmp = opener.node.next?
        while tmp
          next_node = tmp.next?
          tmp.unlink
          child.append_child(tmp)
          tmp = next_node
        end

        node.append_child(child)
        process_emphasis(opener.delimiters)
        remove_bracket
        opener.node.unlink

        unless is_image
          opener = @brackets
          while opener
            opener.active = false unless opener.image
            opener = opener.previous?
          end
        end
      else
        remove_bracket
        @pos = start_pos
        node.append_child(text("]"))
        @delimiters.concat opener.delimiters
      end

      true
    end

    # While parsing, delimiters are just added as text nodes and @delimiters is set.
    # This is called afterward to process @delimiters.
    private def process_emphasis(delims : Array(Delimiter)?)
      delims ||= @delimiters
      strong_opener = nil
      emph_opener = nil
      delims.each do |current|
        matched_emph = false
        matched_strong = false
        case current.num_delims
        when 1
          # If we're looking for an opener
          if emph_opener.nil? && current.can_open
            emph_opener = current
          elsif !emph_opener.nil? && current.can_close
            emph_opener.node.insert_after(Node.new Node::Type::OpenEmphasis)
            current.node.insert_before(Node.new Node::Type::CloseEmphasis)
            matched_emph = true
          end
        when 2
          # If we're looking for an opener
          if strong_opener.nil? && current.can_open
            strong_opener = current
          elsif !strong_opener.nil? && current.can_close
            strong_opener.node.insert_after(Node.new Node::Type::OpenStrong)
            current.node.insert_before(Node.new Node::Type::CloseStrong)
            matched_strong = true
          end
        else
          if current.can_close
            # If it's closing both, need to determine which was opened first.
            if !strong_opener.nil? && !emph_opener.nil?
              # Determine whether strong was opened first.
              if delims.index(strong_opener).not_nil! < delims.index(emph_opener).not_nil!
                emph_opener.node.insert_after(Node.new Node::Type::OpenEmphasis)
                current.node.insert_before(Node.new Node::Type::CloseEmphasis)
                strong_opener.node.insert_after(Node.new Node::Type::OpenStrong)
                current.node.insert_before(Node.new Node::Type::CloseStrong)
              else
                strong_opener.node.insert_after(Node.new Node::Type::OpenStrong)
                current.node.insert_before(Node.new Node::Type::CloseStrong)
                emph_opener.node.insert_after(Node.new Node::Type::OpenEmphasis)
                current.node.insert_before(Node.new Node::Type::CloseEmphasis)
              end
              matched_emph = true
              matched_strong = true
              # If it's not closing both, still make sure it closes either properly.
            else
              if !strong_opener.nil?
                strong_opener.node.insert_after(Node.new Node::Type::OpenStrong)
                current.node.insert_before(Node.new Node::Type::CloseStrong)
                matched_strong = true
              elsif !emph_opener.nil?
                emph_opener.node.insert_after(Node.new Node::Type::OpenEmphasis)
                current.node.insert_before(Node.new Node::Type::CloseEmphasis)
                matched_emph = true
              end
            end
          end
          # Do this second so the same triple asterisk doesn't both close and open.
          if current.can_open
            strong_opener = current if strong_opener.nil?
            emph_opener = current if emph_opener.nil?
          end
        end
        # Remove matched parts of each delimiter.
        if matched_strong && !strong_opener.nil?
          strong_opener.num_delims -= 2
          current.num_delims -= 2
          # Also remove the characters, incase there are some that aren't going to be interpreted as emphasis markers.
          strong_opener.node.text = strong_opener.node.text[0..-3]
          current.node.text = current.node.text[0..-3]
        end
        if matched_emph && !emph_opener.nil?
          emph_opener.num_delims -= 1
          current.num_delims -= 1
          emph_opener.node.text = emph_opener.node.text[0..-2]
          current.node.text = current.node.text[0..-2]
        end
        # If the delimiter nodes used are empty, remove them.
        if !strong_opener.nil? && strong_opener.num_delims == 0
          strong_opener.node.unlink
        end
        if !emph_opener.nil? && emph_opener.num_delims == 0
          emph_opener.node.unlink
        end
        if current.num_delims == 0
          current.node.unlink
        end
        emph_opener = nil if matched_emph
        strong_opener = nil if matched_strong
      end
    end

    private def html_tag(node : Node)
      if text = match(Rule::HTML_TAG)
        child = Node.new(Node::Type::HTMLInline)
        child.text = text
        node.append_child(child)
        true
      else
        false
      end
    end

    private def string(node : Node)
      if text = match_main
        node.append_child(text(text))
        true
      else
        false
      end
    end

    private def link(match : String, email = false) : Node
      dest = match[1..-2]
      destination = email ? "mailto:#{dest}" : dest

      node = Node.new(Node::Type::Link)
      node.data["destination"] = normalize_uri(destination)
      node.append_child(text(dest))
      node
    end

    private def link_destination
      save_pos = @pos
      open_parens = 0
      while char = char_at?(@pos)
        case char
        when '\\'
          @pos += 1
          @pos += 1 if char_at?(@pos)
        when '('
          @pos += 1
          open_parens += 1
        when ')'
          break if open_parens < 1
          @pos += 1
          open_parens -= 1
        when .ascii_whitespace?
          break
        else
          @pos += 1
        end
      end
      dest = @text.byte_slice(save_pos, @pos - save_pos)
      normalize_uri(Utils.escape(dest))
    end

    private def delim(char : Char, node : Node)
      res = scan_delims(char)
      return false unless res

      num_delims = res[:num_delims]
      start_pos = @pos
      @pos += num_delims
      text = @text.byte_slice(start_pos, @pos - start_pos)

      child = text(text)
      node.append_child(child)

      delim_stack = @brackets ? @brackets.not_nil!.delimiters : @delimiters
      delim_stack << Delimiter.new(char, num_delims, num_delims, child, res[:can_open], res[:can_close])
      true
    end

    private def scan_delims(char)
      num_delims = 0
      start_pos = @pos
      while char_at?(@pos) == char
        num_delims += 1
        @pos += 1
      end
      prev_char = start_pos == 0 ? '\n' : previous_unicode_char_at(start_pos)
      next_char = unicode_char_at?(@pos) || '\n'

      @pos = start_pos
      {
        num_delims: num_delims,
        can_open:   !next_char.ascii_whitespace?,
        can_close:  !prev_char.ascii_whitespace?,
      }
    end

    private def space_at_end_of_line?
      while char_at?(@pos) == ' '
        @pos += 1
      end

      case char_at?(@pos)
      when '\n'
        @pos += 1
      when Char::ZERO
      else
        return false
      end
      return true
    end

    # Parse zero or more space characters, including at most one newline
    private def spnl
      seen_newline = false
      while c = char_at?(@pos)
        if !seen_newline && c == '\n'
          seen_newline = true
        elsif c != ' '
          break
        end

        @pos += 1
      end

      return true
    end

    private def match(regex : Regex) : String?
      text = @text.byte_slice(@pos)
      if match = text.match(regex)
        @pos += match.byte_end.not_nil!
        return match[0]
      end
    end

    private def match_main : String?
      # This is the same as match(/^[^\n`\[\]\\!<&*_'"]+/m) but done manually (faster)
      start_pos = @pos
      while (char = char_at?(@pos)) && main_char?(char)
        @pos += 1
      end

      if start_pos == @pos
        nil
      else
        @text.byte_slice(start_pos, @pos - start_pos)
      end
    end

    private def main_char?(char)
      case char
      when '\n', '`', '[', ']', '\\', '!', '<', '&', '*', '_', '\'', '"'
        false
      else
        true
      end
    end

    private def text(text) : Node
      node = Node.new(Node::Type::Text)
      node.text = text.to_s
      node
    end

    private def char_at?(byte_index)
      @text.byte_at?(byte_index).try &.unsafe_chr
    end

    private def char_at(byte_index)
      @text.byte_at(byte_index).unsafe_chr
    end

    private def previous_unicode_char_at(byte_index)
      reader = Char::Reader.new(@text, byte_index)
      reader.previous_char
    end

    private def unicode_char_at?(byte_index)
      return nil if byte_index >= @text.bytesize
      reader = Char::Reader.new(@text, byte_index)
      reader.current_char
    end

    # Normalize reference label: collapse internal whitespace
    # to single space, remove leading/trailing whitespace, case fold.
    def normalize_reference(text : String)
      text[1..-2].strip.downcase.gsub("\n", " ")
    end

    private RESERVED_CHARS = ['&', '+', ',', '(', ')', '#', '*', '!', '#', '$', '/', ':', ';', '?', '@', '=']

    def normalize_uri(uri : String)
      String.build(capacity: uri.bytesize) do |io|
        URI.encode(decode_uri(uri), io) do |byte|
          URI.unreserved?(byte) || RESERVED_CHARS.includes?(byte.chr)
        end
      end
    end

    def decode_uri(text : String)
      decoded = URI.decode(text)
      if decoded.includes?('&') && decoded.includes?(';')
        decoded = decoded.gsub(/^&(\w+);$/) { |chars| chars }
      end
      decoded
    end

    class Bracket
      property node : Node
      property! previous : Bracket?
      property delimiters : Array(Delimiter)
      property index : Int32
      property image : Bool
      property active : Bool
      property bracket_after : Bool

      def initialize(@node, @previous, @delimiters, @index, @image, @active = true)
        @bracket_after = false
      end
    end

    class Delimiter
      property char : Char
      property num_delims : Int32
      property orig_delims : Int32
      property node : Node
      property can_open : Bool
      property can_close : Bool

      def initialize(@char, @num_delims, @orig_delims, @node, @can_open, @can_close)
      end
    end
  end
end
