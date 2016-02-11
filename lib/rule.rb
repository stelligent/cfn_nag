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

  private

  def failing_rule(jq_expression:, fail_if_found:)
    stdout = jq_command(@input_json_path, jq_expression)
    result = $?.exitstatus
    if (fail_if_found and result == 0) or
       (not fail_if_found and result != 0)
      @failure_count ||= 0
      @failure_count += 1
      yield stdout
    end
  end

  def jq_command(input_json_path, jq_expression)
    `cat #{input_json_path} | jq '#{jq_expression}' -e`
  end
end

