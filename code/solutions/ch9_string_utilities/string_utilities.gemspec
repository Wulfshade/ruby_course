require_relative 'lib/string_utilities'

Gem::Specification.new do |spec|
  spec.name          = "string_utilities"
  spec.version       = StringUtilities::VERSION
  spec.authors       = ["Ruby Developer"]
  spec.email         = ["dev@example.com"]

  spec.summary       = "A collection of utility methods for string manipulation"
  spec.description   = "String Utilities provides various helpful methods for string transformation, including titleize, truncate, case conversion, and more."
  spec.homepage      = "https://github.com/example/string_utilities"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/example/string_utilities"
  spec.metadata["changelog_uri"] = "https://github.com/example/string_utilities/blob/master/CHANGELOG.md"

  # Specify which files should be included in the gem
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    *.gemspec
    README.md
    LICENSE.txt
    CHANGELOG.md
  ])
  
  spec.require_paths = ["lib"]
end
