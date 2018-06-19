require "spec_helper"

module Maxima
  describe Rational do
    {
      "1 / 2"  => Rational.new(1, 2),
      "1 / 30" => Rational.new(1, 30),
      "1 / 0"  => Rational.new(1, 0),
      "1 / 1"  => Rational.new(1, 1),
      "0 / 1"  => Float.new(0),
      "a / 1"  => nil,
    }.each do |input, output|
      it "should convert #{input} => #{output}" do
        actual_output = nil
        expect {
          actual_output = Rational.parse(input)
        }.to_not raise_error
        expect(actual_output).to eq(output)
      end
    end
  end
end
