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
    COMPLEX_REGEX = /(-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)((?:\*)?(?:%)?i)?/

    def self.parse(maxima_output)
      string = maxima_output.gsub(WHITESPACE_OR_PARENTHESES_REGEX, "")

      s = string.scan(COMPLEX_REGEX)

      real = 0
      imaginary = 0

      s.each do |(float, is_imaginary)|
        if is_imaginary
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

    def pretty_to_s
      if real == 0
        "#{@imaginary}i"
      else
        operand = @real.positive? ? '+' : '-'
        "#{@imaginary}i #{operand} #{@real.abs}"
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

    def positive?
      @real > 0 && @imaginary > 0
    end

    def negative?
      @real < 0 && @imaginary < 0
    end

    def zero?
      @real == 0 && @imaginary == 0
    end

    def imaginary?
      true
    end

    def real?
      false
    end
  end
end
