module Maxima
  class Polynomial < Unit

    def self.fit(histogram, degrees)
      throw :degrees_must_be_zero_or_positive if degrees < 0

      equation_string, variables = polynomial_equation(degrees)
      results = Maxima.lsquares_estimation(histogram.to_a, [:x, :y], "y = #{equation_string}", variables)

      function = Maxima::Function.new(equation_string)

      {
        mse:      results.delete(:mse),
        function: function.at(results),
      }
    end

    def self.polynomial_equation(degrees, f_of: "x")
      polynomials, constant_variables = [], []

      (degrees + 1).times.each do |degree|
        constant_variable = "c#{degree}"
        constant_variables << constant_variable

        case degree
        when 0
          polynomials << constant_variable
        when 1
          polynomials << "#{constant_variable} * #{f_of}"
        else
          polynomials << "#{constant_variable} * #{f_of} ^ #{degree}"
        end
      end

      [
        polynomials.join(" + "),
        constant_variables
      ]
    end
  end
end
