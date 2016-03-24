require 'minitest/autorun'
require_relative '../lib/calculator'

class CalculatorTest < Minitest::Test
  def setup
  end

  def teardown
  end

  def test_add_two_numbers
    calculator = Calculator.new
    assert(3, calculator.add(1, 2))
  end
end
