module StringUtilities
  VERSION = "0.1.0"

  # Convert a string to title case
  # Example: "hello world" => "Hello World"
  def self.titleize(str)
    str.split.map(&:capitalize).join(' ')
  end

  # Truncate a string to a specified length with ellipsis
  # Example: truncate("Hello World", 7) => "Hello..."
  def self.truncate(str, length = 30, ellipsis = "...")
    return str if str.length <= length
    str[0...(length - ellipsis.length)] + ellipsis
  end

  # Remove all non-alphanumeric characters
  # Example: "Hello, World!" => "HelloWorld"
  def self.alphanumeric(str)
    str.gsub(/[^a-zA-Z0-9]/, '')
  end

  # Convert a string to snake_case
  # Example: "HelloWorld" => "hello_world"
  def self.snake_case(str)
    str.gsub(/::/, '/')
       .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
       .gsub(/([a-z\d])([A-Z])/, '\1_\2')
       .tr("-", "_")
       .downcase
  end

  # Convert a string to camelCase
  # Example: "hello_world" => "helloWorld"
  def self.camel_case(str)
    str.split(/[_-]/).each_with_index.map { |word, i| 
      i == 0 ? word : word.capitalize 
    }.join
  end

  # Convert a string to PascalCase
  # Example: "hello_world" => "HelloWorld"
  def self.pascal_case(str)
    str.split(/[_-]/).map(&:capitalize).join
  end

  # Wrap text at a specified width
  # Example: wrap("Hello World", 5) => "Hello\nWorld"
  def self.wrap(str, width = 80)
    str.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n").strip
  end

  # Count occurrences of a substring in a string
  # Example: count_occurrences("hello world", "l") => 3
  def self.count_occurrences(str, substring)
    str.scan(substring).count
  end
  
  # Check if a string is a palindrome
  # Example: palindrome?("racecar") => true
  def self.palindrome?(str)
    cleaned = str.downcase.gsub(/[^a-z0-9]/, '')
    cleaned == cleaned.reverse
  end

  # Generate random string of specified length
  # Example: random(8) => "a1b2c3d4"
  def self.random(length = 10, chars = nil)
    chars ||= ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    Array.new(length) { chars.sample }.join
  end
end

# Extend String class with utility methods
class String
  def titleize
    StringUtilities.titleize(self)
  end

  def truncate(length = 30, ellipsis = "...")
    StringUtilities.truncate(self, length, ellipsis)
  end

  def alphanumeric
    StringUtilities.alphanumeric(self)
  end

  def to_snake_case
    StringUtilities.snake_case(self)
  end

  def to_camel_case
    StringUtilities.camel_case(self)
  end

  def to_pascal_case
    StringUtilities.pascal_case(self)
  end

  def wrap(width = 80)
    StringUtilities.wrap(self, width)
  end

  def count_occurrences(substring)
    StringUtilities.count_occurrences(self, substring)
  end
  
  def palindrome?
    StringUtilities.palindrome?(self)
  end
end
