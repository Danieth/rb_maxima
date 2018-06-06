require 'parallel'

module Maxima::Interpolate

  MSE = -> (mse:, **) { mse }

  def self.fit(histogram, fit_function_generators: nil, transforms: nil)
    throw :fit_function_generators_cannot_be_nil if fit_function_generators.nil?

    best_functions = Parallel.map(transforms.map(&:to_projections)) do |(projection, inversion)|
      transformed_histogram = histogram.transform(&projection)

      fit_function_generators.flat_map do |fit_function_generator|
        fit_function_generator.flat_map do |f_of_x, variables|

          result = fit_to_equation(
            transformed_histogram.to_a,
            [:x, :y],
            "y = #{f_of_x}",
            variables,
            equation_for_mse: "y = #{inversion.call(f_of_x)}"
          )

          result[:function] = inversion.call(result[:function])
          result
        end
      end
    end

    best_function[:function]
  end

  def self.fit_to_equation(histogram, variables, equation_string, regression_variables, **opts)
    results = Maxima.lsquares_estimation(
      histogram.to_a,
      variables,
      equation_string,
      regression_variables,
      **opts
    )
    mse = results.delete(:mse)

    results.each do |variable, value|
      equation_string.gsub!("(#{variable})", value.string)
    end

    {
      function: Maxima::Function.new(equation_string).simplified,
      mse: mse
    }
  end
end
