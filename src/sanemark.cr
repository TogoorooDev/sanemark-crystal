require "./sanemark/utils"
require "./sanemark/node"
require "./sanemark/rule"
require "./sanemark/options"
require "./sanemark/renderer"
require "./sanemark/parser"
require "./sanemark/version"

module Sanemark
  def self.to_html(source : String, options = Options.new)
    return "" if source.empty?

    document = Parser.parse(source, options)
    renderer = HTMLRenderer.new(options)
    renderer.render(document)
  end
end
