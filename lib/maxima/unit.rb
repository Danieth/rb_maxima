module Maxima
  class Unit
    attr_accessor :maxima_output, :plot_title

    def initialize(inline_maxima_output = nil, plot_title: nil, maxima_output: nil)
      @maxima_output = inline_maxima_output || maxima_output
      @plot_title    = plot_title
    end

    # def inspect
    #   if plot_title.nil? || plot_title == ""
    #     "#{self.class}(#{self})"
    #   else
    #     "#{self.class}[#{plot_title}](#{self})"
    #   end
    # end

    def self.parse(m)
      Rational.parse(m) || Complex.parse(m)
    end

    def to_s
      @maxima_output
    end

    def with_plot_title(plot_title)
      self.class.new(@maxima_output, plot_title)
    end

    %w(* / ** + -).each do |operation|
      define_method(operation) do |other|
        Maxima.bin_op(self, other, operation)
      end
    end

    def absolute_difference(other)
      Function.new("abs(#{self - other})")
    end

    def simplified
      @simplified ||= through_maxima(:expand)
    end

    # ~~ *unary_operations, **unary_operations_options
    def through_maxima(*array_options, **options)
      @after_maxima ||= Command.output(itself: Unit) do |c|
        c.let :itself, self.to_s, *array_options, **options
      end[:itself]
    end

    def simplified!
      simplified.to_s
    end

    def to_maxima_input
      to_s
    end

    def to_gnu_plot
      [gnu_plot_text, gnu_plot_options]
    end

    def at(_)
      self
    end

    def to_pdf(t0, t1, v: "x")
      (self / integral(t0, t1)).definite_integral(t0, v)
    end

    # private
    def gnu_plot_text
      to_s
    end

    def gnu_plot_options
      { w: gnu_plot_w }.tap do |options|
        options[:plot_title] = @plot_title if @plot_title
      end
    end

    def gnu_plot_w
      "points"
    end

    def to_f
      throw "cannot_cast_#{self.class}_to_float"
    end

    def real?
      throw "real_is_undecidable_for_#{self.class}"
    end

    def imaginary?
      throw "imaginary_is_undecidable_for_#{self.class}"
    end

    def positive?
      to_f > 0
    end

    def zero?
      to_f == 0
    end

    def negative?
      to_f < 0
    end

    def ==(other)
      (self <=> other) == 0
    end
  end
end
