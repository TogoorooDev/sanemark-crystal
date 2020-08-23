require "spec"
require "../src/sanemark"

describe Sanemark::Options do
  describe "#base_url" do
    it "it disabled by default" do
      options = Sanemark::Options.new
      Sanemark.to_html("[foo](bar)", options).should eq %(<p><a href="bar">foo</a></p>\n)
      Sanemark.to_html("![](bar)", options).should eq %(<p><img src="bar" alt=""></p>\n)
    end

    it "absolutizes relative urls" do
      options = Sanemark::Options.new
      options.base_url = URI.parse("http://example.com")
      Sanemark.to_html("[foo](bar)", options).should eq %(<p><a href="http://example.com/bar">foo</a></p>\n)
      Sanemark.to_html("[foo](https://example.com/baz)", options).should eq %(<p><a href="https://example.com/baz">foo</a></p>\n)
      Sanemark.to_html("![](bar)", options).should eq %(<p><img src="http://example.com/bar" alt=""></p>\n)
      Sanemark.to_html("![](https://example.com/baz)", options).should eq %(<p><img src="https://example.com/baz" alt=""></p>\n)
    end
  end
end
