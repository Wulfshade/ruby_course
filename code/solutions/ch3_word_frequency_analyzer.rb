#!/usr/bin/env ruby
# Chapter 3: Mini Project - Word Frequency Analyzer

class WordFrequencyAnalyzer
  def initialize(text)
    @text = text
  end
  
  def analyze
    # Break text into words, clean them, and remove empty strings
    words = @text.downcase.gsub(/[^\w\s]/, '').split.reject(&:empty?)
    
    # Count frequency of each word
    frequency = Hash.new(0)
    words.each { |word| frequency[word] += 1 }
    
    # Return hash sorted by frequency (descending)
    frequency.sort_by { |_word, count| -count }.to_h
  end
  
  def top_words(limit = 5)
    analyze.first(limit).to_h
  end
  
  def word_count
    analyze.values.sum
  end
  
  def unique_word_count
    analyze.keys.count
  end
  
  def most_frequent_word
    return nil if analyze.empty?
    analyze.first
  end
  
  def display_stats
    frequency = analyze
    
    puts "==== Word Frequency Analysis ===="
    puts "Total words: #{word_count}"
    puts "Unique words: #{unique_word_count}"
    
    if most_frequent = most_frequent_word
      puts "\nMost frequent word: '#{most_frequent[0]}' (#{most_frequent[1]} occurrences)"
    end
    
    puts "\nTop 5 words:"
    top_words.each_with_index do |(word, count), index|
      puts "#{index + 1}. '#{word}' - #{count} occurrences"
    end
    
    puts "\nWord frequency (all words):"
    frequency.each do |word, count|
      puts "- '#{word}': #{count}"
    end
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  # Sample text - "The Raven" excerpt by Edgar Allan Poe
  sample_text = "Once upon a midnight dreary, while I pondered, weak and weary,
  Over many a quaint and curious volume of forgotten lore—
  While I nodded, nearly napping, suddenly there came a tapping,
  As of someone gently rapping, rapping at my chamber door."
  
  puts "Sample text analysis:"
  puts "--------------------"
  puts sample_text
  puts "\n"
  
  analyzer = WordFrequencyAnalyzer.new(sample_text)
  analyzer.display_stats
  
  # Interactive mode
  puts "\nWould you like to analyze your own text? (y/n)"
  if gets.chomp.downcase == 'y'
    puts "Enter your text (Ctrl+D when finished):"
    user_text = STDIN.read
    
    user_analyzer = WordFrequencyAnalyzer.new(user_text)
    user_analyzer.display_stats
  end
end
