module Maxima
  class Function < Unit
    attr_accessor :variables

    def initialize(string, variables = nil, **options)
      string = string.to_s
      options[:maxima_output] ||= string
      super(**options)
      @variables = variables || Function.variables_in_string(string)
    end

    VARIABLE_REGEX = /(?:\s)?[%|a-z|A-Z]+/.freeze
    IGNORE_VARIABLES = %w(%e %i).freeze
    def self.variables_in_string(string)
      string.scan(VARIABLE_REGEX).uniq - IGNORE_VARIABLES
    end

    def integral(t0 = nil, t1 = nil, v: "x")
      if t0 && t1
        Maxima.integrate(@string, t0, t1, v: v)[:integral]
      else
        Maxima.integrate(@string, v: v)[:integral]
      end
    end

    def definite_integral(t0, t1, v: "x")
      i_v = self.integral(v: v)
      i_v.at(v => t1) - i_v.at(v => t0)
    end

    def derivative(v: "x")
      Maxima.diff(@string, v: v)[:diff]
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
        Unit.parse(string)
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
          if @variables.include?(t)
            s.gsub!(k.to_s, "(#{t})")
          end
        end
      else
        throw "Must specify the variable for at() if the function has more than one variable" if @variables.length != 1
        s.gsub!(@variables.first, "(#{v})")
      end
      Function.new(s).simplified
    end

    def ==(other)
      to_s == other.to_s
    end
  end
end
