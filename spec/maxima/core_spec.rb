module Maxima
  describe Maxima do

    describe "#mformat" do
      {
        "1"                            => "1",
        :x                             => "x",
        1                              => "1",
        { a: 2, b: 3}                  => "a = 2, b = 3",
        [1, 2]                         => "[1,2]",
        { a: [1,3], b: 3}              => "a = [1,3], b = 3",
        [1, { a: 3, b: [2] }, 4]       => "[1,a = 3, b = [2],4]",
        Maxima::Complex.new(2,3)       => "(3 * %i + 2)",
        Complex(1,2)                   => "(2 * %i + 1)",
        Maxima::Function.new("x")      => "x",
        Maxima::Histogram.new([[1,2]]) => "[[1,2]]"
      }.each do |input, output|
        it "should convert #{input} => #{output}" do
          actual_output = nil
          expect {
            actual_output = Maxima.mformat(input)
          }.to_not raise_error
          expect(actual_output).to eq(output)
        end
      end


      it "should throw an exception when formatting nil" do
        expect {
          Maxima.mformat(nil)
        }.to throw_symbol(:cannot_format_nil)
      end

      it "should convert any unknown class into a string" do
        expect(Maxima.mformat(true)).to eq("true")
        expect(Maxima.mformat(false)).to eq("false")
        expect(Maxima.mformat(Set.new([1]))).to eq("#<Set: {1}>")
      end
    end

    describe "#lagrangian_interpolation" do
      describe "should return the lagrangian interpolation of the provided histogram" do
        it "should work for a linear histogram" do
          expect(Maxima.lagrangian_interpolation([[1,2],[3,4],[5,6]])[:function]).to(satisfy { |f| f === Maxima::Function.new("x+1") })
        end

        it "should work for a quadratic histogram" do
          expect(Maxima.lagrangian_interpolation([[2,4],[3,9],[4,16]])[:function]).to(satisfy { |f| f === Maxima::Function.new("x ^ 2") })
        end

        it "should work for any given specific histogram" do
          expect(Maxima.lagrangian_interpolation([[2,4],[3,2],[4,4]])[:function]).to(satisfy { |f| f === Maxima::Function.new("2*x^2-12*x+20") })
        end
      end
    end

    describe "#lagrangian" do
      it "should not throw an exception and return the same result it has in the past" do
        actual_output = nil
        expect {
          actual_output = Maxima.lagrangian("x ^ 10 + y ^ (1/10)", [:x, :y], "x + y - 10", [1,1])
        }.to_not raise_error

        expect(actual_output).to eq(
                                   {
                                     x: Maxima::Float.new(0.4787078489206559),
                                     y: Maxima::Float.new(9.521286271045522)
                                   }
                                 )
      end
    end

    describe "#solve_polynomial" do
      context "given a function with real roots" do
        it "should find all real roots" do
          actual_output = nil
          expect {
            actual_output = Maxima.solve_polynomial("x ^ 2 - 1 = 0", "x", real_only: true)
          }.to_not raise_error

          x_outputs = actual_output.map { |v| v["x"].to_f }
          expect(x_outputs).to eq([1, -1])
        end
      end

      context "given a function with imaginary roots" do
        it "should find all real roots" do
          actual_output = nil
          expect {
            actual_output = Maxima.solve_polynomial("x ^ 2 + 1 = 0", "x", real_only: false)
          }.to_not raise_error

          x_outputs = actual_output.map { |v| v["x"] }
          expect(x_outputs).to eq(
                                 [
                                   Maxima::Complex.new(0, 1),
                                   Maxima::Complex.new(0, -1),
                                 ]
                               )
        end
      end
    end
  end
end
