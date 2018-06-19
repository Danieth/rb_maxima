module Maxima
  class Function < Unit
    attr_accessor :string, :variables

    def initialize(string, variables = nil, **options)
      string = string.to_s
      options[:maxima_output] ||= string
      super(**options)
      @variables = variables || Function.variables_in_string(string)
    end

    # This strategy fails for functions (cos etc.). However, that does not impact it's actual usage.
    VARIABLE_REGEX = /[%|a-z|A-Z]+[0-9|a-z|A-Z]*/.freeze
    VARIABLE_REGEX_LOOK_PATTERN = /[%|0-9|a-z|A-Z]/
    VARIABLE_REPLACEMENT_REGEX = ->(variable) { /(?<!#{VARIABLE_REGEX_LOOK_PATTERN})#{variable}(?!#{VARIABLE_REGEX_LOOK_PATTERN})/ }
    IGNORE_VARIABLES = %w(%e %i).freeze
    def self.variables_in_string(string)
      (string.scan(VARIABLE_REGEX) - IGNORE_VARIABLES).to_set
    end

    def integral(t0 = nil, t1 = nil, v: "x")
      if t0 && t1
        Maxima.integrate(to_maxima_input, t0, t1, v: v)[:integral]
      else
        Maxima.integrate(to_maxima_input, v: v)[:integral]
      end
    end

    def definite_integral(t0, t1, v: "x")
      i_v = self.integral(v: v)
      i_v.at(v => t1) - i_v.at(v => t0)
    end

    def derivative(variable = nil, v: "x")
      Maxima.diff(to_maxima_input, v: (variable || v))[:diff]
    end

    def between(min, max, steps)
      step = (max - min).fdiv(steps)

      Command.output(r: Histogram) do |c|
        c.let :r, "makelist([x,float(#{self})],x, #{min}, #{max}, #{step})"
      end[:r]
    end

    # Assume what we get is what we need
    def self.parse(string)
      variables = variables_in_string(string)

      if variables.any?
        Function.new(string, variables)
      else
        Unit.parse_float(string)
      end
    rescue
      nil
    end

    def gnu_plot_text
      super.gsub("^", "**")
    end

    def gnu_plot_w
      "lines"
    end

    def to_maxima_input
      self.to_s
    end

    def at(v)
      s = self.to_s.dup

      case v
      when Hash
        v.each do |k,t|
          k = k.to_s
          if @variables.include?(k)
            s.gsub!(VARIABLE_REPLACEMENT_REGEX.call(k), "(#{t})")
          end
        end
      else
        throw :must_specify_variables_in_hash if @variables.length != 1
        s.gsub!(VARIABLE_REPLACEMENT_REGEX.call(@variables.first), "(#{v})")
      end
      Function.parse(s).simplified
    end

    def ==(other)
      to_s == other.to_s
    end
  end
end
