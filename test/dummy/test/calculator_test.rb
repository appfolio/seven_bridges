require 'minitest/autorun'
require_relative '../lib/calculator'

class CalculatorTest < Minitest::Test
  def test_add
    calculator = Calculator.new
    assert_equal(3, calculator.add(1, 2))
  end

  def test_multiply
    calculator = Calculator.new
    assert_equal(12, calculator.multiply(3, 4))
  end

  def test_add_10_and_multiply_by_3
    calculator = Calculator.new
    assert_equal(36, calculator.add_10_and_multiply_by_3(2))
  end

  def test_square
    calculator = Calculator.new
    assert_equal(36, calculator.square(6))
  end

  def test_get_circle_area
    calculator = Calculator.new
    assert_equal(78.5, calculator.get_circle_area(5))
  end
end
