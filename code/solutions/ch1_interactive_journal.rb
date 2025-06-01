# Chapter 1: Mini Project - Interactive Journal

# Ask the user for their name
puts "Welcome to your Interactive Journal!"
print "Please enter your name: "
user_name = gets.chomp

# Display a welcome message
puts "Hello, #{user_name}! Let's write in your journal today."

# Get today's date
require 'date'
today = Date.today
date_string = today.strftime("%Y-%m-%d")

# Ask user for journal entry
puts "Please enter your journal entry for today (#{date_string}):"
puts "(Press Enter twice when finished)"

# Collect the entry (continue until user enters a blank line)
entry_lines = []
while true
  line = gets.chomp
  break if line.empty?
  entry_lines << line
end

journal_entry = entry_lines.join("\n")

# Save entry to a file
filename = "#{date_string}-journal.txt"
File.open(filename, "w") do |file|
  file.puts "Date: #{date_string}"
  file.puts "Name: #{user_name}"
  file.puts "Entry:"
  file.puts journal_entry
end

# Display confirmation message
puts "Journal entry saved to #{filename} (#{journal_entry.length} characters)"
