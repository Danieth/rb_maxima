require 'parallel'
require 'csv'

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
        *CSV.read(csv).map { |array| array.map(&:to_i) }
      )
    end

    # def polynomial_fit(from: 0, to: 1, degree: nil)
    #   from = to = degree if degree
    #   polynomials = (from..to).map do |degrees|
    #     Polynomial.fit(self, degrees)
    #   end
    #   best_polynomial = polynomials.min_by { |h| h[:mse].to_f }
    #   best_polynomial[:function]
    # end

    def self.parse(s)
      Histogram.new((eval s), string: s)
    end

    def initialize(*points)
      while points.is_a?(Array) && points.first.is_a?(Array) && points.first.first.is_a?(Array)
        points = points.flatten(1)
      end

      unless points.is_a?(Array) && points.first.is_a?(Array) && points.first.length == 2
        throw :invalid_histogram_points
      end
      @points = points
    end

    def to_percentage()
      @to_percentage ||=
        begin
          sum = points.sum(&:x)
          Histogram.new(
            points.map do |point|
              Point.new(
                point.x,
                point.y.fdiv(sum)
              )
            end
          )
        end
    end

    def to_a
      @points
    end

    def integral()
      begin
        sum = 0
        Histogram.new(
          points.map do |(one, two)|
            sum += two
            [one, sum]
          end
        )
      end
    end

    def to_gnu_plot()
      [*points.map(&:to_a).transpose, w: "points"]
    end
  end
end
