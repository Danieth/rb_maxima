require "spec_helper"

module Maxima
  describe Float do

    describe "#Float" do
      it { expect(Maxima.Float(1)).to eq(Float.new(1)) }
    end

    (-10..10).step(2).each do |float|
      describe "#real?" do
        context "always real" do
          it { expect(Maxima.Float(float).real?).to eq(true) }
        end

        describe "#imaginary?" do
          context "never imaginary" do
            it { expect(Maxima.Float(float).imaginary?).to eq(false) }
          end
        end
      end
    end

    POSITIVE_REAL = (1..10).map { |float| Maxima.Float(float) }
    NEGATIVE_REAL = (-1..-10).map { |float| Maxima.Float(float) }
    NON_ZERO_REAL = ((-10..-1).to_a + (1..10).to_a).map { |float| Maxima.Float(float) }
    ZERO_REAL     = %w(0).map { |float| Maxima.Float(float) }

    POSITIVE_REAL.each do |float|
      context "positive" do
        it { expect(float).to satisfy("#{float} is positive") { |f| f.positive? } }
        it { expect(float).not_to satisfy("#{float} is negative") { |f| f.negative? } }
      end
    end

    NEGATIVE_REAL.each do |float|
      context "negative" do
        it { expect(float).not_to satisfy("#{float} is positive") { |f| f.positive? } }
        it { expect(float).to satisfy("#{float} is negative") { |f| f.negative? } }
      end
    end

    NON_ZERO_REAL.each do |float|
      context "non zero real" do
        it { expect(float).to satisfy("#{float} is real") { |f| f.real? } }
        it { expect(float).not_to satisfy("#{float} is zero") { |f| f.zero? } }
        it { expect(float).not_to satisfy("#{float} is imaginary") { |f| f.imaginary? } }
      end
    end

    ZERO_REAL.each do |float|
      context "zero" do
        it { expect(float).to satisfy("#{float} is real") { |f| f.real? } }
        it { expect(float).to satisfy("#{float} is zero") { |f| f.zero? } }
        it { expect(float).not_to satisfy("#{float} is imaginary") { |f| f.imaginary? } }
      end
    end
  end
end
