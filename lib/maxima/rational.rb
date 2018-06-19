module Maxima
  class Rational < Unit

    attr_accessor :numerator, :denominator

    def initialize(numerator, denominator, **options)
      super(**options)
      @numerator = numerator
      @denominator = denominator
    end

    REGEX = /\s*(\d+)\s*\/\s*(\d+)\s*/
    def self.parse(maxima_output)
      _, numerator, denominator = REGEX.match(maxima_output).to_a

      return if numerator.nil? || denominator.nil?

      if numerator == 0
        Float.new(0, maxima_output: maxima_output)
      else
        Rational.new(numerator.to_f, denominator.to_f, maxima_output: maxima_output)
      end
    rescue StandardError
      nil
    end

    def real?
      true
    end

    def imaginary?
      false
    end

    def to_f
      @to_f ||= numerator.fdiv(denominator)
    end

    def <=>(other)
      case other
      when ::Float, ::Rational, Float, Rational
        self.to_f <=> other.to_f
      else
        -1
      end
    end
  end
end
