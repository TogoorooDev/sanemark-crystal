require "./spec_helper"

describe_spec("fixtures/spec.md", Sanemark::Options.new(allow_html: true))

describe_spec("fixtures/regression.md", Sanemark::Options.new(allow_html: true))

describe_spec("fixtures/spoilers.md", Sanemark::Options.new(spoilers: true))
