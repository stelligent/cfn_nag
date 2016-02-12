module Rule
  attr_accessor :input_json_path, :failure_count

  def warning(jq_expression)
    stdout = jq_command(@input_json_path, jq_expression)
    result = $?.exitstatus
    if result == 0
      @warning_count ||= 0
      @warning_count += 1
      yield stdout
    end
  end

  def fatal_assertion(jq_expression, &action)
    failing_rule(jq_expression: jq_expression,
                 fail_if_found: false,
                 fatal: true,
                 &action)
  end

  def fatal_violation(jq_expression, &action)
    failing_rule(jq_expression: jq_expression,
                 fail_if_found: true,
                 fatal: true,
                 &action)
  end

  def violation(jq_expression, &action)
    failing_rule(jq_expression: jq_expression,
                 fail_if_found: true,
                 &action)
  end

  def assertion(jq_expression, &action)
    failing_rule(jq_expression: jq_expression,
                 fail_if_found: false,
                 &action)
  end

  def message(message_type, message, violating_code=nil)
    (1..60).each { print '-' }
    puts
    puts "| #{message_type.upcase}"
    puts '|'
    puts "| #{message}"

    unless violating_code.nil?
      puts '|'
      puts indent_multiline_string_with_prefix('|', violating_code.to_s)
    end
  end

  private

  def indent_multiline_string_with_prefix(prefix, multiline_string)
    prefix + ' ' + multiline_string.gsub(/\n/, "\n#{prefix} ")
  end

  def failing_rule(jq_expression:, fail_if_found:, fatal: false)
    stdout = jq_command(@input_json_path, jq_expression)
    result = $?.exitstatus
    if (fail_if_found and result == 0) or
       (not fail_if_found and result != 0)
      @violation_count ||= 0
      @violation_count += 1
      puts "VIO: #{@violation_count}"
      yield stdout

      if fatal
        exit 1
      end
    end
  end

  def jq_command(input_json_path, jq_expression)
    command = "cat #{input_json_path} | jq '#{jq_expression}' -e"
    #puts command
    `#{command}`
  end
end

