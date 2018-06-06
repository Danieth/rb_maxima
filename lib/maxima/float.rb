module Maxima

  def self.Float(real)
    Float.new(real)
  end

  class Float < Unit
    attr_accessor :real

    def initialize(real = nil, **options)
      options[:maxima_output] ||= real&.to_s
      super(**options)
      @real = (real || @maxima_output).to_f
    end

    def <=>(other)
      case other
      when ::Float
        @real <=> other
      when Float
        @real <=> other.real
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
  end
end
