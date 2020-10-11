module Sanemark
  abstract class Renderer
    def initialize(@options = Options.new)
      @output_io = String::Builder.new
      @last_output = "\n"
    end

    def lit(string : String)
      @output_io << string
      @last_output = string
    end

    def cr
      lit("\n") if @last_output != "\n"
    end

    def render(document : Node)
      Utils.timer("renderering", @options.time) do
        walker = document.walker
        while event = walker.next
          node, entering = event
          case node.type
          when Node::Type::Heading
            heading(node, entering)
          when Node::Type::List
            list(node, entering)
          when Node::Type::Item
            item(node, entering)
          when Node::Type::BlockQuote
            block_quote(node, entering)
          when Node::Type::ThematicBreak
            thematic_break(node, entering)
          when Node::Type::CodeBlock
            code_block(node, entering)
          when Node::Type::Code
            code(node, entering)
          when Node::Type::HTMLBlock
            html_block(node, entering)
          when Node::Type::HTMLInline
            html_inline(node, entering)
          when Node::Type::Paragraph
            paragraph(node, entering)
          when Node::Type::OpenEmphasis, Node::Type::OpenStrong, Node::Type::OpenSpoiler
            open_delim(node)
          when Node::Type::CloseEmphasis, Node::Type::CloseStrong, Node::Type::CloseSpoiler
            close_delim(node)
          when Node::Type::SoftBreak
            soft_break(node, entering)
          when Node::Type::LineBreak
            line_break(node, entering)
          when Node::Type::Link
            link(node, entering)
          when Node::Type::Image
            image(node, entering)
          else
            text(node, entering)
          end
        end
      end

      @output_io.to_s.sub("\n", "")
    end
  end
end

require "./renderers/*"
