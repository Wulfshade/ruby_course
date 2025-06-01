#!/usr/bin/env ruby
# Chapter 7: Mini Project - Calculator TDD Tests

require 'minitest/autorun'
require_relative 'ch7_calculator'

class CalculatorTest < Minitest::Test
  def setup
    @calculator = Calculator.new
  end
  
  # Addition tests
  def test_adds_positive_numbers
    assert_equal 5, @calculator.add(2, 3)
  end
  
  def test_adds_negative_numbers
    assert_equal -5, @calculator.add(-2, -3)
  end
  
  # Subtraction tests
  def test_subtracts_positive_numbers
    assert_equal 3, @calculator.subtract(5, 2)
  end
  
  def test_subtracts_with_negative_result
    assert_equal -1, @calculator.subtract(2, 3)
  end
  
  # Multiplication tests
  def test_multiplies_positive_numbers
    assert_equal 6, @calculator.multiply(2, 3)
  end
  
  def test_multiplies_negative_numbers
    assert_equal 6, @calculator.multiply(-2, -3)
  end
  
  def test_multiplies_positive_and_negative
    assert_equal -6, @calculator.multiply(2, -3)
  end
  
  # Division tests
  def test_divides_positive_numbers
    assert_equal 2.5, @calculator.divide(5, 2)
  end
  
  def test_raises_error_when_dividing_by_zero
    assert_raises ZeroDivisionError do
      @calculator.divide(5, 0)
    end
  end
  
  # Power tests
  def test_calculates_power
    assert_equal 8, @calculator.power(2, 3)
  end
  
  def test_calculates_power_with_negative_exponent
    assert_in_delta 0.25, @calculator.power(2, -2), 0.001
  end
  
  # Square root tests
  def test_calculates_square_root
    assert_equal 3.0, @calculator.square_root(9)
  end
  
  def test_raises_error_for_negative_square_root
    assert_raises ArgumentError do
      @calculator.square_root(-9)
    end
  end
end
