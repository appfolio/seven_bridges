require_relative '../config/initializers/seven_bridges_initializer'
require_relative './stupid_math'

class Calculator
  def add(a, b)
    a + b
  end

  def multiply(a, b)
    sum = 0
    b.times do
      sum = add(sum, a)
    end
    sum
  end

  def add_10_and_multiply_by_3(a)
    ans = add(a, 10)
    multiply(ans, 3)
  end

  def square(x)
    multiply(x, x)
  end

  def get_circle_area(radius)
    multiply(StupidMath.get_approx_pi, square(radius))
  end
end
