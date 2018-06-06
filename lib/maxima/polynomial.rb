module Maxima
  class Polynomial < Unit

    def self.fit(histogram, degrees)
      equation_string, variables = polynomial_equation(degrees)

      results = Maxima.lsquares_estimation(histogram.to_a, [:x, :y], "y = #{equation_string}", variables)

      mse = results.delete(:mse)

      results.each do |variable, value|
        equation_string.gsub!("(#{variable})", value.to_s)
      end

      {
        function: Maxima::Function.new(equation_string).simplified,
        mse: mse
      }
    end

    def self.fit_function(min, max, x: "x")
      Enumerator.new do |e|
        (min..max).each do |degrees|
          equation_string, variables = polynomial_equation(degrees, f_of: x)
          e.<<(equation_string, variables)
        end
      end
    end

    def self.polynomial_equation(degrees, f_of: "x")
      [
        degrees.times.map do |degree|
          degree == 0 ? "(c#{degree})" : "(c#{degree}) * #{f_of} ^ #{degree}"
        end.join(" + "),
        degrees.times.map { |degree| "c#{degree}" }
      ]
    end
  end
end
