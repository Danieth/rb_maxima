module Maxima
  class Command
    attr_accessor :dependencies, :commands, :assigned_variables, :options

    def initialize
      @dependencies = []
      @assigned_variables = Set.new()
      @commands = []
      @options = {}
    end

    def self.output(*v)
      Command.new()
        .with_options(
          use_fast_arrays: true,
          float: true
        ).tap do |c|
        yield c
      end.output_variables(*v)
    end

    def with_options(options)
      self.tap { @options.merge!(options) }
    end

    def add_variable(variable)
      case variable
      when Enumerable
        @assigned_variables.merge(variable)
      else
        @assigned_variables.add(variable)
      end
    end

    def let(variable_or_variables, expression, *unary_operations, **unary_operations_options)
      add_variable(variable_or_variables)


      variable   = Maxima.mformat(variable_or_variables)
      expression = _apply_unary_operations(expression, *unary_operations, **unary_operations_options)

      _let(variable, expression)
    end

    def let_simplified(variable, expression, *unary_operations, **unary_operations_options)
      unary_operations_options[:expand] = true

      let(
        variable,
        expression,
        *unary_operations,
        **unary_operations_options
      )
    end

    def _let(variable, expression)
      @commands << "#{variable} : #{expression}"
    end

    def <<(expression)
      @commands << expression
    end

    def _apply_unary_operations(expression, *unary_operations, **unary_operations_options)
      unary_operations = Set.new(unary_operations)
      unary_operations_options.map do |option, is_enabled|
        unary_operations.add(option) if is_enabled
      end

      [
        unary_operations.map { |unary_operation| "#{unary_operation}(" },
        Maxima.mformat(expression),
        ")" * unary_operations.count
      ].join()
    end

    OPTIONS = {
      float:           -> (enabled) { "float: #{enabled}" },
      use_fast_arrays: -> (enabled) { "use_fast_arrays: #{enabled}" },
      real_only:       -> (enabled) { "realonly: #{enabled}" }
    }

    def options_commands()
      [].each do |commands|
        @options.each do |option, configuration|
          # warn that option is not applicable
          next unless OPTIONS[option]
          commands << OPTIONS[option].call(configuration)
        end
      end
    end

    def run_shell(extract_variables = nil, debug: ENV["DEBUG_RB_MAXIMA"])
      inputs = [*dependencies_input, *options_commands(), *@commands]

      inputs << "grind(#{extract_variables.join(', ')})" if extract_variables
      input = inputs.join("$\n") + "$\n"

      output = with_debug(debug, input) do
        Helper.spawn_silenced_shell_process("maxima --quiet --run-string '#{input}'")
      end

      {
        input:  input,
        output: output
      }
    end

    def with_debug(debug, input)
      return yield unless debug

      uuid = SecureRandom.uuid[0..6]
      puts input.lines.map { |s| "#{uuid}>>>\t#{s}" }.join

      yield.tap do |output|
        puts output.lines.map { |s| "#{uuid}<<<\t#{s}" }.join
      end
    end

    MATCH_REGEX = -> (eol_maxima_characters) { /(?<=\(%i#{eol_maxima_characters}\)).*(?=\$|\Z)/m.freeze }
    GSUB_REGEX = Regexp.union(/\s+/, /\(%(i|o)\d\)|done/)
    def self.extract_outputs(output, eol_maxima_characters)
      MATCH_REGEX.call(eol_maxima_characters)
        .match(output)[0]
        .gsub(GSUB_REGEX, "")
        .split("$")
    end

    def self.convert_output_to_variables(output_variable_map, raw_output)
      {}.tap do |result|
        output_variable_map.each_with_index do |(variable, klazz), index|
          output = raw_output[index]
          output = klazz.respond_to?(:parse) ? klazz.parse(output) : klazz.new(output)
          result[variable] = output
        end
      end
    end

    def self.expand_output_variable_map(output_variable_map)
      {}.tap do |expanded_output_variable_map|
        add_key = -> (k,v) {
          if expanded_output_variable_map.has_key?(k)
            throw :key_used_twice
          else
            expanded_output_variable_map[k] = v
          end
        }

        output_variable_map.each do |output_key, parsed_into_class|
          case output_key
          when Array
            output_key.each do |output_subkey|
              add_key.call(output_subkey, parsed_into_class)
            end
          else
            add_key.call(output_key, parsed_into_class)
          end
        end
      end
    end

    def self.eol_maxima_characters(input)
      input.count("$") + input.count(";")
    end

    def output_variables(output_variable_map)
      output_variable_map = Command.expand_output_variable_map(output_variable_map)

      input, output = run_shell(output_variable_map.keys).values_at(:input, :output)

      eol_maxima_characters = Command.eol_maxima_characters(input)
      extracted_outputs = Command.extract_outputs(output, eol_maxima_characters)

      Command.convert_output_to_variables(output_variable_map, extracted_outputs)
    end

    def dependencies_input
      @dependencies.map { |s| "load(#{s})" }
    end
  end
end
