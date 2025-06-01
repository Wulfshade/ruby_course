#!/usr/bin/env ruby
# Chapter 7: Mini Project - Calculator class implementation

class Calculator
  def add(a, b)
    a + b
  end
  
  def subtract(a, b)
    a - b
  end
  
  def multiply(a, b)
    a * b
  end
  
  def divide(a, b)
    raise ZeroDivisionError, "Cannot divide by zero" if b.zero?
    a / b.to_f
  end
  
  def power(base, exponent)
    base ** exponent
  end
  
  def square_root(number)
    raise ArgumentError, "Cannot calculate square root of negative number" if number < 0
    Math.sqrt(number)
  end
end
