module Maxima
  describe Function do

    describe "#variables_in_string" do
      {
        "1"  => [].to_set,
        "x"  => %w(x).to_set,
        "x + x ^ 2 + x ^ 93" => %w(x).to_set,
        "x + y"  => %w(x y).to_set,
        "x + y * %i"  => %w(x y).to_set,
        "x - y"  => %w(x y).to_set,
        "y ^ 34"  => %w(y).to_set,
        "y ^ 34 + x * 0"  => %w(y x).to_set,
      }.each do |input, output|
        it "should return #{output} for the function #{input}" do
          actual_output = nil
          expect {
            actual_output = Function.variables_in_string(input)
          }.to_not raise_error
          expect(actual_output).to eq(output)
        end
      end
    end

    describe "#derivative" do
      context "assuming the derivative should be taken with respect to x" do
        {
          "1"  => "0",
          "x ^ 2" => "2 * x",
          "y ^ 2 + x ^ 2" => " 2 * x"
        }.each do |input, output|
          it "should return #{output} for the function #{input}" do
            actual_output = nil
            expect {
              actual_output = Function.parse(input).derivative
            }.to_not raise_error
            expect(actual_output).to satisfy("equivalence") { |f| f === Function.parse(output) }
          end
        end
      end

      it "should work for derivatives taken with respect to other variables" do
        f = Function.parse("x ^ 2 + y ^ 2").derivative(v: :y)
        expect(f).to satisfy("equivalence") { |f| f === Function.parse("2 * y") }

        f = Function.parse("x ^ 3 + y ^ 3 + z ^ 19 - 8").derivative(:z)
        expect(f).to satisfy("equivalence") { |f| f === Function.parse("19 * z ** 18") }
      end
    end

    describe "#parse" do
      {
        nil         => NilClass,
        "1"         => Float,
        "x"         => Function,
        "y"         => Function,
        "x + y"     => Function,
        "x + y ^ 2" => Function,
      }.each do |input, output|
        it "should return #{output} class for the function #{input}" do
          actual_output = nil
          expect {
            actual_output = Function.parse(input)
          }.to_not raise_error
          expect(actual_output.class).to eq(output)
        end
      end
    end

    VALUES = [-100, 0, 100, 7, 9]
    describe "#at" do
      context "one variable" do
        context "linear function" do
          let(:function) { Function.new("x") }

          it do
            VALUES.each do |float|
              result = float
              expect(function).to satisfy("equal #{result} at #{float}") { |f| f.at(float).to_f == result }
              expect(function).to satisfy("equal #{result} at x => #{float}") { |f| f.at(x: float).to_f == result }
            end
          end

        end

        context "quadratic function" do
          let(:function) { Function.new("x ^ 2 + x") }

          it do
            VALUES.each do |float|
              result = float ** 2 + float
              expect(function).to satisfy("equal #{result} at #{float}") { |f| f.at(float).to_f == result }
              expect(function).to satisfy("equal #{result} at x => #{float}") { |f| f.at(x: float).to_f == result }
            end
          end
        end

        context "two variable function" do
          let(:function) { Function.new("x + y") }

          it do
            expect { function.at(1) }.to throw_symbol(:must_specify_variables_in_hash)

            VALUES.each do |float_x|
              VALUES.each do |float_y|
                result = float_x + float_y
                expect(function).to satisfy("equal #{result} at x => #{float_x}, y => #{float_y}") { |f| f.at(x: float_x, y: float_y).to_f == result }
              end
            end
          end
        end


      end
    end



  end
end
