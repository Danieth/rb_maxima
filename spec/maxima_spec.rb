require "spec_helper"

describe Maxima do

  describe "Sanity Tests" do
    it "should correctly parse values" do
      expect(
        Maxima::Function.new("5.0 + x").to_s
      ).to eq("5.0 + x")

      expect(
        Maxima::Function.new("5.0 + x").through_maxima.to_s
      ).to eq("x+5.0")

      %w(3*x x+4 x+100 x-10).each do |simple_expression|
        expect(
          Maxima::Function.new(simple_expression).simplified.to_s
        ).to eq(simple_expression)
      end
    end
  end

  describe "'core'" do
    describe "#bin_op" do
      %w(+ - * /).each do |op|
        describe "#{op} should work" do
          it "should work for #{op}" do
            result = Maxima::Function.new("((5.0) #{op} (x))")

            expect(
              Maxima::Float.new(5.0).send(op, Maxima::Function.new(:x))
            ).to eq(result)

            result = Maxima::Function.new("((x) #{op} (5.0))")
            expect(
              Maxima::Function.new(:x).send(op, Maxima::Float.new(5.0))
            ).to eq(result)

            result = Maxima::Function.new("((5.0) #{op} (5.0))")
            expect(
              Maxima::Float.new(5.0).send(op, Maxima::Float.new(5.0))
            ).to eq(result)
          end
        end
      end
    end
  end
end
