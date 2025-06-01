#!/usr/bin/env ruby
# Chapter 4: Mini Project - Custom Iterator

class FibonacciSequence
  include Enumerable
  
  def initialize(limit)
    @limit = limit
  end
  
  # Implement each method required for Enumerable
  def each
    return to_enum(:each) unless block_given?
    
    a, b = 0, 1
    count = 0
    
    while count < @limit
      yield a
      a, b = b, a + b
      count += 1
    end
  end
end

class PrimeSequence
  include Enumerable
  
  def initialize(limit)
    @limit = limit
  end
  
  def each
    return to_enum(:each) unless block_given?
    
    count = 0
    num = 2
    
    while count < @limit
      if prime?(num)
        yield num
        count += 1
      end
      num += 1
    end
  end
  
  private
  
  def prime?(number)
    return false if number <= 1
    return true if number <= 3
    return false if number % 2 == 0 || number % 3 == 0
    
    i = 5
    while i * i <= number
      return false if number % i == 0 || number % (i + 2) == 0
      i += 6
    end
    
    true
  end
end

class Range
  # Custom step iterator for Range
  def step_by(step)
    return to_enum(:step_by, step) unless block_given?
    
    current = self.begin
    while current <= self.end
      yield current
      current += step
    end
  end
end

# Demonstration
if __FILE__ == $PROGRAM_NAME
  puts "=== Fibonacci Sequence ==="
  fib = FibonacciSequence.new(10)
  
  puts "First 10 Fibonacci numbers:"
  puts fib.to_a.join(", ")
  
  puts "\nSum of first 10 Fibonacci numbers:"
  puts fib.reduce(:+)
  
  puts "\nFirst 10 Fibonacci numbers multiplied by 2:"
  puts fib.map { |n| n * 2 }.join(", ")
  
  puts "\nFibonacci numbers greater than 10 in the sequence:"
  puts fib.select { |n| n > 10 }.join(", ")
  
  puts "\n=== Prime Sequence ==="
  primes = PrimeSequence.new(10)
  
  puts "First 10 prime numbers:"
  puts primes.to_a.join(", ")
  
  puts "\n=== Custom Range Iterator ==="
  puts "Range 1 to 20 with step 3:"
  puts (1..20).step_by(3).to_a.join(", ")
  
  puts "\nBONUS: Combining iterators"
  puts "Every 2nd Fibonacci number up to the 10th:"
  enum = fib.each_with_index.select { |_, i| i.even? }.map { |n, _| n }
  puts enum.join(", ")
  
  puts "\nFirst 5 primes squared:"
  puts PrimeSequence.new(5).map { |n| n ** 2 }.join(", ")
end
