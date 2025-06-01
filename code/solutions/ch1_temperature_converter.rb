# Chapter 1: Mini Project - Temperature Converter

# Define a temperature in Celsius
celsius_temp = 30

# Convert it to Fahrenheit using the formula: F = C * 9/5 + 32
fahrenheit_temp = (celsius_temp * 9.0 / 5.0) + 32.0

# Display both temperatures
puts "Temperature in Celsius: #{celsius_temp}°C"
puts "Temperature in Fahrenheit: #{fahrenheit_temp}°F"

# Compare the two temperatures and display whether the Fahrenheit value is
# greater than, less than, or equal to the Celsius value
if fahrenheit_temp > celsius_temp
  puts "The Fahrenheit temperature (#{fahrenheit_temp}°F) is greater than the Celsius temperature (#{celsius_temp}°C)."
elsif fahrenheit_temp < celsius_temp
  puts "The Fahrenheit temperature (#{fahrenheit_temp}°F) is less than the Celsius temperature (#{celsius_temp}°C)."
else
  puts "The Fahrenheit temperature (#{fahrenheit_temp}°F) is equal to the Celsius temperature (#{celsius_temp}°C)."
end

# BONUS: Convert Fahrenheit to Celsius as well
puts "\n--- BONUS: Fahrenheit to Celsius ---"
original_fahrenheit = 98.6
original_celsius = (original_fahrenheit - 32.0) * 5.0 / 9.0
puts "Temperature in Fahrenheit: #{original_fahrenheit}°F"
puts "Converted to Celsius: #{original_celsius}°C"
