module Maxima
  class Histogram < Unit
    attr_accessor :points

    def self.between(min, max, function = ->(x) { x }, steps = 100)
      Histogram.new(
        *[].tap do |points|
          (min..max).step((max - min).fdiv(steps)).each do |x|
            points.push([x, function.call(x)])
          end
        end
      )
    end

    def polynomial_fit(degrees)
      Polynomial.fit(self, degrees)[:function]
    end

    def self.from_csv(csv)
      Histogram.new(
        *CSV.read(csv).map { |array| array.map(&:to_f) }
      )
    end

    def self.parse(s)
      Histogram.new((eval s), maxima_output: s)
    end

    def initialize(*points, **options)
      super(**options)

      while points.is_a?(Array) && points.first.is_a?(Array) && points.first.first.is_a?(Array)
        points = points.flatten(1)
      end

      unless points.is_a?(Array) && points.first.is_a?(Array) && points.first.length == 2
        throw :invalid_histogram_points
      end

      @points = points
    end

    def to_a
      @points
    end

    # PDF
    def to_percentage()
      @to_percentage ||=
        begin
          sum = points.sum(&:last)
          Histogram.new(
            points.map do |(x,y)|
              [
                x,
                y.fdiv(sum)
              ]
            end
          )
        end
    end

    # literal CDF
    def integral()
      begin
        sum = 0
        Histogram.new(
          points.map do |(x, y)|
            sum += y
            [x, sum]
          end
        )
      end
    end

    def to_gnu_plot()
      [*points.map(&:to_a).transpose, w: "points"]
    end

    def <=>(other)
      case other
      when Array, Histogram
        self.to_a <=> other.to_a
      else
        -1
      end
    end
  end
end
