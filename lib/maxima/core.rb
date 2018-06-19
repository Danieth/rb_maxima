module Maxima
  def self.bin_op(e_1, e_2, bin_op)
    Maxima::Function.new("((#{Maxima.mformat(e_1)}) #{bin_op} (#{Maxima.mformat(e_2)}))")
  end

  ## Alternative minimization function that needs it's own testing etc.
  # def self.cobyla(minimize_function, variables, constraint_function, initial_guess)
  #   Command.output(variables => Unit) do |c|
  #     initial_guess = mformat(initial_guess)

  #     c.dependencies << "cobyla"

  #     c.let :output, "fmin_cobyla(#{minimize_function}, #{mformat(variables)}, #{initial_guess},constraints = #{constraint_function})"
  #     c.let variables, "sublis(output[1], #{variables})"
  #   end
  # end

  def self.lagrangian_interpolation(array)
    Command.output(function: Function) do |c|
      c.dependencies << "interpol"
      c.let :array, array
      c.let_simplified :function, "lagrange(array)"
    end
  end

  def self.integrate(function, t0 = nil, t1 = nil, v: "x")
    expression = (t0 && t1) ? "integrate(function, #{v}, #{t0}, #{t1})" : "integrate(function, #{v})"

    Command.output(integral: Function) do |c|
      c.let :function, function
      c.let :integral, expression
    end
  end

  def self.diff(function, v: "x")
    Command.output(diff: Function) do |c|
      c.let :function, function
      c.let :diff, "derivative(function, #{v})"
    end
  end

  def self.plot(*maxima_objects, from_x: nil, from_y: nil)
    maxima_objects << [[from_x.min, 0], [from_x.max, 0]] if from_x
    maxima_objects << [[0, from_y.min], [0, to_y.max]] if from_y

    maxima_objects = maxima_objects.map do |k|
      if k.respond_to?(:to_gnu_plot)
        k.to_gnu_plot
      elsif k.is_a?(Array) && !k.first.is_a?(String)
        [*k.transpose, w: "points"]
      else
        k
      end
    end

    Helper.stfu do
      Numo.gnuplot do |c|
        c.debug_on
        c.set title: "Maxima Plot"
        c.plot(*maxima_objects)
      end
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
      if outputs.count == 1
        c << "map (lhs, lsquares_estimation) :: map (rhs, lsquares_estimation)"
      else
        c << "map (lhs, lsquares_estimation[1]) :: map (rhs, lsquares_estimation[1])"
      end
      c.let :mse, "lsquares_residual_mse(M, #{formatted_variables}, #{equation_for_mse}, first (lsquares_estimation))"
    end
  end

  def self.equivalence(expression_one, expression_two)
    Command.output(:is_equal => Boolean) do |c|
      formatted_expression_one = mformat(expression_one)
      formatted_expression_two = mformat(expression_two)

      c.let :is_equal, "is(equal(#{formatted_expression_one}, #{formatted_expression_two}))"
    end
  end

  def self.lagrangian(minimize_function, variables, constraint_function, initial_guess, iterations: 5)
    Command.output(variables => Unit) do |c|
      variables           = mformat(variables)
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
    when String
      variable # the only truly `valid` input is a string
    when Hash
      variable.map do |key,value|
        "#{mformat(key)} = #{mformat(value)}"
      end.join(", ")
    when Array, Histogram
      "[" + variable.to_a.map { |v| mformat(v) }.join(",") + "]"
    when ::Complex
      mformat Complex.new(variable.real, variable.imag)
    when Numeric
      mformat Float(variable)
    when Complex, Float, Function
      variable.to_maxima_input
    when nil
      throw :cannot_format_nil
    else # Symbol, etc.
      variable.to_s
    end
  end

  def self.solve_polynomial(equations, variables_to_solve_for, ignore: nil, real_only: false)
    variables_to_solve_for = Array(variables_to_solve_for)
    equations = Array(equations)

    throw :all_equations_must_include_equivalence unless equations.all? { |e| e.include?("=") }

    # regex match extract
    output = Command.output(output: Unit) do |c|
      c.with_options(real_only: real_only)

      variables = mformat(variables_to_solve_for)
      equations = mformat(equations)

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
