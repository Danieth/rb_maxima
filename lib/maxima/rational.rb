module Maxima
  class Rational < Unit

    attr_accessor :numerator, :denominator

    def initialize(string, numerator, denominator, title = nil)
      super(string, title)
      @numerator = numerator
      @denominator = denominator
    end

    REGEX = /(\d+)\/(\d+)/
    def self.parse(input_string)
      _, numerator, denominator = REGEX.match(input_string).to_a

      return nil if numerator.nil? || denominator.nil?

      if numerator == 0
        Float.new(input_string, 0)
      else
        Rational.new(input_string, numerator.to_i, denominator.to_i)
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
  end
end
