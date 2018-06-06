require "spec_helper"

module Maxima
  describe Complex do
    describe "#parse" do
      {
        "1 + 2 + a"       => Maxima.Float(3),
        "1 + 2 + 3i"      => Maxima.Complex(3, 3),
        "1 + 2 + 3%i"     => Maxima.Complex(3, 3),
        "1 + 2 + i3"      => Maxima.Float(6),
        "3i"              => Maxima.Complex(0, 3),
        "0"               => Maxima.Float(0),
        "0i"              => Maxima.Float(0),
        ""                => Maxima.Float(0),
      }.each do |input, output|
        it "should convert #{input} => #{output}" do
          actual_output = nil
          expect {
            actual_output = Complex.parse(input)
          }.to_not raise_error
          expect(actual_output).to eq(output)
        end
      end
    end
  end
end
