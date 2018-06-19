module Maxima

  def self.Float(real)
    Float.new(real)
  end

  class Float < Unit
    ZERO = Float.new(0).freeze

    attr_accessor :real

    def initialize(real = nil, **options)
      options[:maxima_output] ||= real&.to_s
      super(**options)
      @real = (real || @maxima_output).to_f
    end

    def <=>(other)
      case other
      when ::Float, Float
        @real <=> other.to_f
      else
        -1
      end
    end

    def to_f
      @real
    end

    def real?
      true
    end

    def imaginary?
      false
    end

    def derivative(v: nil)
      ZERO
    end
  end
end
