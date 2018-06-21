require "spec_helper"

module Maxima
  describe Command do
    let(:command) { Command.new() }

    it "should be creatable" do
      expect { command }.to_not raise_error
    end

    describe "#options_commands" do
      it "should begin with no options" do
        expect(Command.new().options_commands).to eq([])
      end

      it "should contain all valid options converted into the correct string format" do
        expect(Command.new().options_commands).to eq([])
        expect(Command.new().with_options(float: true).options_commands).to eq(["float: true"])
        expect(Command.new().with_options(float: false).options_commands).to eq(["float: false"])

        expect(Command.new().with_options(use_fast_arrays: true).options_commands).to eq(["use_fast_arrays: true"])
        expect(Command.new().with_options(real_only: true).options_commands).to eq(["realonly: true"])

        expect(Command.new().with_options(float: true, use_fast_arrays: true, real_only: false).options_commands).to eq(["float: true", "use_fast_arrays: true", "realonly: false"])
      end
    end

    describe "#output_variables" do
      it "should work with a single assignment" do
        command.let(:a, 4.0)
        a = command.output_variables(a: Float)[:a]
        expect(a.to_f).to eq(4.0)
      end

      it "should work with multiple assignments" do
        command.let(:a, 5.0)
        command.let(:b, 6.0)
        command.let(:c, "a * b")
        b, c = command.output_variables(b: Float, c: Float).values_at(:b, :c)

        expect(b.to_f).to eq(6.0)
        expect(c.to_f).to eq(30.0)
      end
    end

    describe "#extract_outputs" do

      context "basic output" do
        let(:output) {
          %{
            i : ((5.0) + (x))$
            grind(i)$
            (%i1)

            (%i2)

            x+5.0$

            (%i3)
          }
        }

        it "should work" do
          expect(
            Command.extract_outputs(output, 2)
          ).to eq(["x+5.0"])
        end
      end
    end

    describe "#eol_maxima_characters" do
      it "should count ; and $" do
        expect(Command.eol_maxima_characters(";")).to eq(1)
        expect(Command.eol_maxima_characters("$")).to eq(1)
        expect(Command.eol_maxima_characters("$;;$$")).to eq(5)
        expect(Command.eol_maxima_characters("aa$aa")).to eq(1)
        expect(Command.eol_maxima_characters("abcdf")).to eq(0)
      end
    end

    describe "#convert_output_to_variables" do
      it "should convert multiple output variables" do
        expect(
          Command.convert_output_to_variables(
            {
              a: Float,
              b: Float
            },
            %w(1.0 4.0)
          )
        ).to eq(a: Float.new(1.0), b: Float.new(4.0))
      end
    end


    describe "#expand_output_variable_map" do
      it "should expand keys with arrays into flat keys" do
        expect(
          Command.expand_output_variable_map([:a, :b, :c] => Float, d: Float)
        ).to eq(a: Float, b: Float, c: Float, d: Float)
      end

      it "should throw an exception if expanding the keys would cause a collision" do
        expect {
          Command.expand_output_variable_map([:d] => Float, d: Float)
        }.to throw_symbol(:key_used_twice)
      end
    end

  end
end
