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


  end
end
