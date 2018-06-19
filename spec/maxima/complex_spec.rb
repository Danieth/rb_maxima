require "spec_helper"

module Maxima
  describe Complex do
    describe "#parse" do
      {
        "1 + 2 + a"       => Maxima.Float(3),
        "1 + 2 + 3i"      => Maxima.Complex(3, 3),
        "1 + 2 + 3%i"     => Maxima.Complex(3, 3),
        "%i"              => Maxima.Complex(0, 1),
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

    POSITIVE_COMPLEX   = (1..10).flat_map { |float| [Complex.parse(float), Complex.parse("#{float.to_f}%i")] }
    NEGATIVE_COMPLEX   = (-1..-10).flat_map { |float| [Complex.parse(float), Complex.parse("#{float.to_f}%i")] }
    ZERO_COMPLEX       = %w(0%i).map { |float| Complex.parse(float) }
    NON_ZERO_COMPLEX = ((-10..-1).to_a + (1..10).to_a).map { |float| Complex.parse("#{float.to_f}%i") }

    POSITIVE_COMPLEX.each do |float|
      context "positive" do
        it { expect(float).to satisfy("#{float} is positive") { |f| f.positive? } }
        it { expect(float).not_to satisfy("#{float} is negative") { |f| f.negative? } }
      end
    end

    NEGATIVE_COMPLEX.each do |float|
      context "negative" do
        it { expect(float).not_to satisfy("#{float} is positive") { |f| f.positive? } }
        it { expect(float).to satisfy("#{float} is negative") { |f| f.negative? } }
      end
    end

    NON_ZERO_COMPLEX.each do |float|
      context "non zero imaginary" do
        it { expect(float).not_to satisfy("#{float} is real") { |f| f.real? } }
        it { expect(float).not_to satisfy("#{float} is zero") { |f| f.zero? } }
        it { expect(float).to satisfy("#{float} is imaginary") { |f| f.imaginary? } }
      end
    end

    ZERO_COMPLEX.each do |float|
      context "zero" do
        it { expect(float).to satisfy("#{float} is real") { |f| f.real? } }
        it { expect(float).to satisfy("#{float} is zero") { |f| f.zero? } }
        it { expect(float).not_to satisfy("#{float} is imaginary") { |f| f.imaginary? } }
      end
    end
  end
end
