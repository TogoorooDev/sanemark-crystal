require "html"

module Sanemark::Parser
  class Inline
    include Parser

    property refmap
    private getter! brackets

    @delimiters : Delimiter?

    def initialize(@options : Options)
      @text = ""
      @pos = 0
      @refmap = {} of String => String
    end

    def parse(node : Node)
      @pos = 0
      @delimiters = nil
      @text = node.text.chomp("\n")

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
            when '*', '_'
              handle_delim(char, node)
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
      child.text = contents.gsub '\n', ' '
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
      @brackets = Bracket.new(node, @brackets, @delimiters, index, image, true)
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

      ref_label = nil
      unless matched
        # Next, see if there's a link label
        before_label = @pos
        label_size = link_label
        # The size includes the brackets.
        if label_size > 2
          ref_label = normalize_reference(@text.byte_slice(before_label, label_size + 1))
        elsif !opener.bracket_after
          # Empty or missing second label means to use the first label as the reference.
          # The reference must not contain a bracket. If we know there's a bracket, we don't even bother checking it.
          ref_label = normalize_reference(@text.byte_slice(opener.index, start_pos - opener.index))
        end

        if label_size == 0
          # If shortcut reference link, rewind before spaces we skipped.
          @pos = save_pos
        end

        if ref_label && @refmap[ref_label]?
          # lookup rawlabel in refmap
          dest = @refmap[ref_label]
          matched = true
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
        process_emphasis(opener.previous_delimiter)
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
      end

      true
    end

    private def process_emphasis(delimiter : Delimiter?)
      # find first closer above stack_bottom:
      closer = @delimiters
      while closer
        previous = closer.previous?
        break if previous == delimiter
        closer = previous
      end

      if closer
        openers_bottom = {
          '_'  => delimiter,
          '*'  => delimiter,
        } of Char => Delimiter?

        # move forward, looking for closers, and handling each
        while closer
          closer_char = closer.char

          unless closer.can_close
            closer = closer.next?
            next
          end

          # found emphasis closer. now look back for first matching opener:
          opener = closer.previous?
          opener_found = false
          while opener && opener != delimiter && opener != openers_bottom[closer_char]
            odd_match = (closer.can_open || opener.can_close) &&
                        (opener.orig_delims + closer.orig_delims) % 3 == 0
            if opener.char == closer.char && opener.can_open && !odd_match
              opener_found = true
              break
            end
            opener = opener.previous?
          end
          opener = nil unless opener_found

          old_closer = closer

          case closer_char
          when '*', '_'
            unless opener
              closer = closer.next?
            else
              # calculate actual number of delimiters used from closer
              use_delims = (closer.num_delims >= 2 && opener.num_delims >= 2) ? 2 : 1
              opener_inl = opener.node
              closer_inl = closer.node

              # remove used delimiters from stack elts and inlines
              opener.num_delims -= use_delims
              closer.num_delims -= use_delims

              opener_inl.text = opener_inl.text[0..(-use_delims - 1)]
              closer_inl.text = closer_inl.text[0..(-use_delims - 1)]

              # build contents for new emph element
              emph = Node.new((use_delims == 1) ? Node::Type::Emphasis : Node::Type::Strong)

              tmp = opener_inl.next?
              while tmp && tmp != closer_inl
                next_node = tmp.next?
                tmp.unlink
                emph.append_child(tmp)
                tmp = next_node
              end

              opener_inl.insert_after(emph)

              # remove elts between opener and closer in delimiters stack
              remove_delimiter_between(opener, closer)

              # if opener has 0 delims, remove it and the inline
              if opener.num_delims == 0
                opener_inl.unlink
                remove_delimiter(opener)
              end

              if closer.num_delims == 0
                closer_inl.unlink
                tmp_stack = closer.next?
                remove_delimiter(closer)
                closer = tmp_stack
              end
            end
          else
            nil
          end

          if !opener && !odd_match
            openers_bottom[closer_char] = old_closer.previous?
            remove_delimiter(old_closer) if !old_closer.can_open
          end
        end
      end

      # remove all delimiters
      while (curr_delimiter = @delimiters) && curr_delimiter != delimiter
        remove_delimiter(curr_delimiter)
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

    private def link_label
      text = match(Rule::LINK_LABEL)
      # I assume markd limited label length to 1000 for security reasons?
      # Ensure its closing bracket isn't escaped.
      if text && text.size <= 1001 && (!text.ends_with?("\\]") || text[-3]? == '\\')
        text.bytesize - 1
      else
        0
      end
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

    private def handle_delim(char : Char, node : Node)
      res = scan_delims(char)
      return false unless res

      num_delims = res[:num_delims]
      start_pos = @pos
      @pos += num_delims
      text = @text.byte_slice(start_pos, @pos - start_pos)

      child = text(text)
      node.append_child(child)

      delimiter = Delimiter.new(char, num_delims, num_delims, child, @delimiters, nil, res[:can_open], res[:can_close])

      if prev = delimiter.previous?
        prev.next = delimiter
      end

      @delimiters = delimiter

      true
    end

    private def remove_delimiter(delimiter : Delimiter)
      if prev = delimiter.previous?
        prev.next = delimiter.next?
      end

      if nxt = delimiter.next?
        nxt.previous = delimiter.previous?
      else
        # top of stack
        @delimiters = delimiter.previous?
      end
    end

    private def remove_delimiter_between(bottom : Delimiter, top : Delimiter)
      if bottom.next? != top
        bottom.next = top
        top.previous = bottom
      end
    end

    private def scan_delims(char : Char)
      num_delims = 0
      start_pos = @pos
      while char_at?(@pos) == char
        num_delims += 1
        @pos += 1
      end

      return if num_delims == 0

      char_before = start_pos == 0 ? '\n' : previous_unicode_char_at(start_pos)
      char_after = unicode_char_at?(@pos) || '\n'

      # Match ASCII code 160 => \xA0 (See http://www.adamkoch.com/2009/07/25/white-space-and-character-160/)
      after_is_whitespace = char_after.ascii_whitespace? || char_after == '\u00A0'
      after_is_punctuation = !!char_after.to_s.match(Rule::PUNCTUATION)
      before_is_whitespace = char_before.ascii_whitespace? || char_after == '\u00A0'
      before_is_punctuation = !!char_before.to_s.match(Rule::PUNCTUATION)

      left_flanking = !after_is_whitespace &&
                      (!after_is_punctuation || before_is_whitespace || before_is_punctuation)
      right_flanking = !before_is_whitespace &&
                       (!before_is_punctuation || after_is_whitespace || after_is_punctuation)

      case char
      when '_'
        can_open = left_flanking && (!right_flanking || before_is_punctuation)
        can_close = right_flanking && (!left_flanking || after_is_punctuation)
      else
        can_open = left_flanking
        can_close = right_flanking
      end

      @pos = start_pos

      {
        num_delims: num_delims,
        can_open:   can_open,
        can_close:  can_close,
      }
    end

    def reference(text : String, refmap)
      @text = text
      @pos = 0

      startpos = @pos
      match_chars = link_label

      # label
      return 0 if match_chars == 0
      raw_label = @text.byte_slice(0, match_chars + 1)

      # colon
      if char_at?(@pos) == ':'
        @pos += 1
      else
        @pos = startpos
        return 0
      end

      # link url
      spnl
      dest = link_destination

      if dest.size == 0
        @pos = startpos
        return 0
      end

      unless char_at?(@pos) == '\n'
        @pos = startpos
        return 0
      end
      @pos += 1

      normal_label = normalize_reference(raw_label)
      # Fail if the normalized label is empty.
      if normal_label.empty?
        @pos = startpos
        return 0
      end

      refmap[normal_label] = dest
      return @pos - startpos
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
      if byte_index < @text.bytesize
        reader = Char::Reader.new(@text, byte_index)
        reader.current_char
      else
        nil
      end
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
      property previous_delimiter : Delimiter?
      property index : Int32
      property image : Bool
      property active : Bool
      property bracket_after : Bool

      def initialize(@node, @previous, @previous_delimiter, @index, @image, @active = true)
        @bracket_after = false
      end
    end

    class Delimiter
      property char : Char
      property num_delims : Int32
      property orig_delims : Int32
      property node : Node
      property! previous : Delimiter?
      property! next : Delimiter?
      property can_open : Bool
      property can_close : Bool

      def initialize(@char, @num_delims, @orig_delims, @node,
                     @previous, @next, @can_open, @can_close)
      end
    end
  end
end
