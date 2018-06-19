require "spec_helper"

module Maxima
  describe Polynomial do
    describe "#polynomial_equation" do
      it { expect(Polynomial.polynomial_equation(0, f_of: :x)).to eq(["c0", %w(c0)]) }
      it { expect(Polynomial.polynomial_equation(1, f_of: :x)).to eq(["c0 + c1 * x", %w(c0 c1)]) }
      it { expect(Polynomial.polynomial_equation(2, f_of: :x)).to eq(["c0 + c1 * x + c2 * x ^ 2", %w(c0 c1 c2)]) }
      it { expect(Polynomial.polynomial_equation(2, f_of: :y)).to eq(["c0 + c1 * y + c2 * y ^ 2", %w(c0 c1 c2)]) }
    end

    describe "#fit" do
      it { expect(Polynomial.fit([[1,1],[2,2],[3,3]], 1)).to eq({ function: Maxima::Function.new("x"), mse: Float(0) }) }
    end
  end
end
