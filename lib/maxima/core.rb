module Maxima
  def self.bin_op(e_1, e_2, bin_op)
    Maxima::Function.new("((#{Maxima.mformat(e_1)}) #{bin_op} (#{Maxima.mformat(e_2)}))")
  end

  def self.cobyla(minimize_function, variables, constraint_function, initial_guess)
    Command.output(variables => Unit) do |c|
      initial_guess = mformat(initial_guess)

      c.dependencies << "cobyla"

      c.let :output, "fmin_cobyla(#{minimize_function}, #{mformat(variables)}, #{initial_guess},constraints = #{constraint_function})"
      c.let variables, "sublis(output[1], #{variables})"
    end
  end

  def self.lsquares_estimation(points, variables, equation, outputs, equation_for_mse: equation)
    Command.output(outputs => Complex, :mse => Float) do |c|
      formatted_points    = points.map { |a| mformat(a) }.join(",")
      formatted_variables = mformat(variables)
      formatted_outputs   = mformat(outputs)

      c.dependencies << "lsquares"
      c.let :M, "matrix(#{formatted_points})"
      c.let :lsquares_estimation, "lsquares_estimates(M, #{formatted_variables}, #{equation}, #{formatted_outputs})"
      c.let outputs, "sublis(lsquares_estimation[1], #{formatted_outputs})"
      c.let :mse, "lsquares_residual_mse(M, #{formatted_variables}, #{equation_for_mse}, first (output))"
    end
  end

  def self.lagrangian(minimize_function, variables, constraint_function, initial_guess, iterations: 5)
    Command.output(variables => Unit) do |c|
      initial_guess       = mformat(initial_guess)
      constraint_function = mformat(Array(constraint_function))
      optional_args       = mformat(niter: iterations)

      c.dependencies << "lbfgs"
      c.dependencies << "augmented_lagrangian"

      c.let :output, "augmented_lagrangian_method(#{minimize_function}, #{variables}, #{constraint_function}, #{initial_guess}, #{optional_args})"
      c.let variables, "sublis(output[1], #{variables})"
    end
  end

  def self.mformat(variable)
    case variable
    when String, Symbol
      variable # the only truly `valid` input is a string
    when Hash
      variable.map do |key,value|
        "#{mformat(key)} = #{mformat(value)}"
      end.join(", ")
    when Array
      "[" + variable.map { |v| mformat(v) }.join(",") + "]"
    when ::Complex
      Complex.new(variable, variable.real, variable.imag).to_maxima_input
    when Numeric
      Float(variable).to_maxima_input
    when Complex, Float, Function
      variable.to_maxima_input
    when nil
      throw :cannot_format_nil
    else
      variable
    end
  end

  def self.solve_polynomial(equations, variables_to_solve_for, ignore: nil, real_only: false)
    # regex match extract
    output = Command
               .with_options(real_only: real_only)
               .output(output: Unit) do |c|
      variables = mformat(Array(variables_to_solve_for))
      equations = mformat(Array(equations))

      c.let :output, "algsys(#{equations},#{variables})"
    end

    output = output[:output]

    variables_to_solve_for -= Array(ignore)

    variable_regexes = variables_to_solve_for.map do |variable|
      "#{variable}=(-?.*?)(?:\,|\\])"
    end

    regex = Regexp.new(variable_regexes.reduce(&:+))

    output = output.to_s.gsub(" ", "")

    output.scan(regex).map { |row| variables_to_solve_for.zip(row.map { |v| Unit.parse(v) }).to_h }
  end
end
