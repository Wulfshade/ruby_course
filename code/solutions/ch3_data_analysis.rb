#!/usr/bin/env ruby
# Chapter 3: Mini Project - Data Analysis

class DataAnalyzer
  attr_reader :data
  
  def initialize(data)
    @data = data
  end
  
  # Basic statistics
  def minimum
    @data.min
  end
  
  def maximum
    @data.max
  end
  
  def range
    maximum - minimum
  end
  
  def sum
    @data.sum
  end
  
  def count
    @data.size
  end
  
  def mean
    return 0 if @data.empty?
    sum.to_f / count
  end
  
  def median
    return 0 if @data.empty?
    sorted = @data.sort
    mid = count / 2
    
    if count.odd?
      sorted[mid]
    else
      (sorted[mid-1] + sorted[mid]) / 2.0
    end
  end
  
  def mode
    return nil if @data.empty?
    
    # Count occurrences of each value
    frequency = Hash.new(0)
    @data.each { |value| frequency[value] += 1 }
    
    # Find the most frequent value(s)
    max_frequency = frequency.values.max
    
    # Return all values that appear with the maximum frequency
    frequency.select { |_, count| count == max_frequency }.keys
  end
  
  def variance
    return 0 if count <= 1
    
    mean_value = mean
    sum_squared_differences = @data.sum { |value| (value - mean_value) ** 2 }
    sum_squared_differences.to_f / count
  end
  
  def standard_deviation
    Math.sqrt(variance)
  end
  
  # Data transformations
  def normalize
    min_val = minimum
    max_val = maximum
    range_val = range
    
    return [0] * count if range_val == 0
    
    @data.map { |value| (value - min_val) / range_val.to_f }
  end
  
  def filter_outliers(std_dev_threshold = 2)
    mean_val = mean
    std_dev = standard_deviation
    
    @data.reject do |value|
      (value - mean_val).abs > std_dev_threshold * std_dev
    end
  end
  
  # Simple percentile calculation
  def percentile(p)
    return nil if @data.empty?
    return @data.first if @data.size == 1
    
    sorted = @data.sort
    rank = p / 100.0 * (count - 1)
    
    # If rank is an integer, return the value at that position
    if rank.to_i == rank
      sorted[rank.to_i]
    else
      # Otherwise, interpolate between the two closest values
      lower_value = sorted[rank.to_i]
      upper_value = sorted[rank.to_i + 1]
      lower_value + (upper_value - lower_value) * (rank - rank.to_i)
    end
  end
  
  # Summary of all statistics
  def summary
    {
      count: count,
      minimum: minimum,
      maximum: maximum,
      range: range,
      sum: sum,
      mean: mean,
      median: median,
      mode: mode,
      variance: variance,
      standard_deviation: standard_deviation,
      quartiles: {
        q1: percentile(25),
        q2: percentile(50),
        q3: percentile(75)
      }
    }
  end
  
  # Print a summary report
  def print_summary
    stats = summary
    
    puts "===== Data Analysis Summary ====="
    puts "Count: #{stats[:count]}"
    puts "Minimum: #{stats[:minimum]}"
    puts "Maximum: #{stats[:maximum]}"
    puts "Range: #{stats[:range]}"
    puts "Sum: #{stats[:sum]}"
    puts "Mean: #{stats[:mean].round(2)}"
    puts "Median: #{stats[:median]}"
    puts "Mode: #{stats[:mode].inspect}"
    puts "Variance: #{stats[:variance].round(2)}"
    puts "Standard Deviation: #{stats[:standard_deviation].round(2)}"
    puts "Quartiles:"
    puts "  - Q1 (25%): #{stats[:quartiles][:q1].round(2)}"
    puts "  - Q2 (50%): #{stats[:quartiles][:q2].round(2)}"
    puts "  - Q3 (75%): #{stats[:quartiles][:q3].round(2)}"
    puts "=================================="
  end
end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  # Sample data: Student exam scores
  exam_scores = [72, 84, 67, 91, 78, 83, 88, 94, 65, 75, 77, 82, 95, 60, 79, 81, 87, 90, 73, 85]
  
  # Create analyzer and show summary
  analyzer = DataAnalyzer.new(exam_scores)
  
  puts "Original Data: #{exam_scores.join(', ')}"
  puts
  
  analyzer.print_summary
  
  # Demonstrate data transformations
  puts "\n=== Normalized Data ==="
  normalized = analyzer.normalize
  puts normalized.map { |val| val.round(2) }.join(', ')
  
  puts "\n=== Data Without Outliers ==="
  filtered = analyzer.filter_outliers
  puts filtered.join(', ')
  puts "Removed #{exam_scores.size - filtered.size} outliers"
  
  # Bonus: Compare with extreme outlier added
  puts "\n=== Analysis With Outlier Added ==="
  extreme_data = exam_scores + [25]
  extreme_analyzer = DataAnalyzer.new(extreme_data)
  extreme_analyzer.print_summary
  
  # Show how outlier detection works
  puts "\n=== Filtered Extreme Data ==="
  extreme_filtered = extreme_analyzer.filter_outliers
  puts extreme_filtered.join(', ')
  puts "Removed #{extreme_data.size - extreme_filtered.size} outliers"
end
