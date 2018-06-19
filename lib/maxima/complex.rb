module Maxima

  def self.Complex(real, imaginary)
    Complex.new(real, imaginary)
  end

  class Complex < Unit
    attr_accessor :real, :imaginary

    def initialize(real, imaginary, **options)
      super(**options)
      @real = real
      @imaginary = imaginary
    end

    WHITESPACE_OR_PARENTHESES_REGEX = /(\s|\(|\))/
    COMPLEX_REGEX = /(-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)((?:\*)?(?:%)?\s*i)?|((?:\s*)-?%i)/

    def self.parse(maxima_output)
      maxima_output = maxima_output.to_s unless maxima_output.is_a?(String)
      string = maxima_output.gsub(WHITESPACE_OR_PARENTHESES_REGEX, "")

      real = 0
      imaginary = 0

      string.scan(COMPLEX_REGEX) do |(float, is_imaginary, is_just_imaginary_one)|
        if is_just_imaginary_one
          imaginary += (is_just_imaginary_one.start_with? "-") ? -1 : 1
        elsif is_imaginary
          imaginary += float.to_f
        else
          real += float.to_f
        end
      end

      if imaginary == 0
        Float.new(real, maxima_output: maxima_output)
      else
        Complex.new(real, imaginary, maxima_output: maxima_output)
      end
    end

    def to_maxima_input
      return "#{@imaginary} * %i" if real == 0

      operand = @real.positive? ? '+' : '-'
      "(#{@imaginary} * %i #{operand} #{@real.abs})"
    end

    def ==(other)
      @real == other.real && @imaginary == other.imaginary
    end

    # Definitions are somewhat contrived and not per se mathematically accurate.
    def positive?
      !negative?
    end

    # At least one scalar must be negative & the others non positive
    def negative?
      (@real < 0 && @imaginary <= 0) ||
      (@imaginary < 0 && @real <= 0)
    end

    def zero?
      @real == 0 && @imaginary == 0
    end

    def imaginary?
      @imaginary != 0
    end

    def real?
      @imaginary == 0
    end
  end
end
