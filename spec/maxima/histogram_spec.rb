require "spec_helper"

module Maxima
  describe Histogram do
    describe "#between" do
      it "should work for basic values" do
        expect(Histogram.between(0,10, ->(x) { x }, 2)).to eq([[0,0],[5,5],[10,10]])
        expect(Histogram.between(0,10, ->(x) { x }, 5)).to eq([[0,0],[2,2],[4,4],[6,6],[8,8],[10,10]])
      end
    end

    describe "#polynomial_fit" do

      describe "given a quadratic histogram" do
        let(:histogram) { Histogram.between(0,10, ->(x) { x ** 2 }, 5) }
        let(:expected_result) { Maxima::Function.parse("x ^ 2") }

        it { expect(histogram.polynomial_fit(2)).to satisfy("equivalence with #{expected_result}") { |f| f === expected_result } }
      end

    end

    describe "#to_percentage" do
      describe "given a basic histogram" do
        let(:histogram) { Histogram.new([[0,0],[1,1],[2,2],[3,4]]) }

        it "should convert the y values of the histogram to a percentage of the current sum" do
          expect(histogram.to_percentage()).to eq(
                                                 [
                                                   [0,0],
                                                   [1,1.fdiv(7)],
                                                   [2,2.fdiv(7)],
                                                   [3,4.fdiv(7)],
                                                 ]
                                               )
        end
      end
    end

    describe "#integral" do
      describe "given a basic histogram" do
        let(:histogram) { Histogram.new([[0,0],[1,1],[2,2],[3,4]]) }

        it "should convert the y values of the histogram to a percentage of the current sum" do
          expect(histogram.integral()).to eq(
                                            [
                                              [0,0],
                                              [1,1],
                                              [2,3],
                                              [3,7],
                                            ]
                                          )
        end
      end
    end
  end
end
