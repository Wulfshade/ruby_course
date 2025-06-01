# Chapter 1: Mini Project - Data Type Explorer

# Declare variables of each data type
my_integer = 42
my_float = 3.14159
my_string = "Ruby is fun!"
my_boolean_true = true
my_boolean_false = false
my_nil = nil
my_symbol = :ruby
my_array = [1, 2, 3, "four", :five]
my_hash = {name: "Ruby", year: 1995, creator: "Yukihiro Matsumoto"}

# Print the value and class of each variable
puts "Integer: #{my_integer} (#{my_integer.class})"
puts "Float: #{my_float} (#{my_float.class})"
puts "String: #{my_string} (#{my_string.class})"
puts "Boolean (true): #{my_boolean_true} (#{my_boolean_true.class})"
puts "Boolean (false): #{my_boolean_false} (#{my_boolean_false.class})"
puts "Nil: #{my_nil} (#{my_nil.class})"
puts "Symbol: #{my_symbol} (#{my_symbol.class})"
puts "Array: #{my_array} (#{my_array.class})"
puts "Hash: #{my_hash} (#{my_hash.class})"

# Experiments with type conversion
puts "\nType Conversion Examples:"
puts "String to Integer: '123' => #{'123'.to_i} (#{'123'.to_i.class})"
puts "String to Float: '3.14' => #{'3.14'.to_f} (#{'3.14'.to_f.class})"
puts "Integer to String: 42 => #{42.to_s} (#{42.to_s.class})"
puts "Float to Integer: 9.99 => #{9.99.to_i} (#{9.99.to_i.class})"

# Create a hash about myself
my_info = {
  name: "Ruby Student",
  age: 25,
  favorite_language: "Ruby",
  learning_since: 2025,
  hobbies: ["coding", "reading", "hiking"]
}

# Print the hash information
puts "\nMy Information:"
puts "Name: #{my_info[:name]}"
puts "Age: #{my_info[:age]}"
puts "Favorite Programming Language: #{my_info[:favorite_language]}"
puts "Learning Since: #{my_info[:learning_since]}"
puts "Hobbies: #{my_info[:hobbies].join(', ')}"
