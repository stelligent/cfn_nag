require 'logging'

module Rule
  attr_accessor :input_json_path, :failure_count

  def resources
    '.Resources|with_entries(.value.LogicalResourceId = .key)[]'
  end

  def resources_by_type(resource)
    "#{resources}| select(.Type == \"#{resource}\")"
  end

  def warning(jq:, message:)
    Logging.logger['log'].debug jq

    stdout = jq_command(@input_json_path, jq)
    result = $?.exitstatus
    scrape_jq_output_for_error(stdout)

    resource_ids = parse_logical_resource_ids(stdout)
    new_warnings = resource_ids.size
    if result == 0 and new_warnings > 0
      @warning_count ||= 0
      @warning_count += new_warnings

      message(message_type: 'warning',
              message: message,
              logical_resource_ids: resource_ids)
    end
  end

  def raw_fatal_assertion(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: false,
                 fatal: true,
                 message: message,
                 message_type: 'fatal assertion',
                 raw: true)
  end

  def fatal_assertion(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: false,
                 fatal: true,
                 message: message,
                 message_type: 'fatal assertion')
  end

  def raw_fatal_violation(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: true,
                 fatal: true,
                 message: message,
                 message_type: 'fatal violation',
                 raw: true)
  end

  def fatal_violation(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: true,
                 fatal: true,
                 message: message,
                 message_type: 'fatal violation')
  end

  def violation(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: true,
                 message: message,
                 message_type: 'violation')
  end

  def assertion(jq:, message:)
    failing_rule(jq_expression: jq,
                 fail_if_found: false,
                 message: message,
                 message_type: 'assertion')
  end

  def message(message_type:,
              message:,
              logical_resource_ids: nil,
              violating_code: nil)

    if logical_resource_ids == []
      logical_resource_ids = nil
    end

    (1..60).each { print '-' }
    puts
    puts "| #{message_type.upcase}"
    puts '|'
    puts "| Resources: #{logical_resource_ids}" unless logical_resource_ids.nil?
    puts '|' unless logical_resource_ids.nil?
    puts "| #{message}"

    unless violating_code.nil?
      puts '|'
      puts indent_multiline_string_with_prefix('|', violating_code.to_s)
    end
  end

  private

  def parse_logical_resource_ids(stdout)
    JSON.load(stdout)
  end

  def scrape_jq_output_for_error(stdout)
    fail 'json rule is likely not complete' if stdout.match /jq: error/
  end

  def indent_multiline_string_with_prefix(prefix, multiline_string)
    prefix + ' ' + multiline_string.gsub(/\n/, "\n#{prefix} ")
  end

  def failing_rule(jq_expression:,
                   fail_if_found:,
                   message:,
                   message_type:,
                   fatal: false,
                   raw: false)
    Logging.logger['log'].debug jq_expression

    stdout = jq_command(@input_json_path, jq_expression)
    result = $?.exitstatus
    scrape_jq_output_for_error(stdout)
    if (fail_if_found and result == 0) or
       (not fail_if_found and result != 0)
      @violation_count ||= 0

      if raw
        @violation_count += 1

        message(message_type: message_type,
                message: message,
                violating_code: stdout)

        if fatal
          exit 1
        end
      else
        resource_ids = parse_logical_resource_ids(stdout)
        @violation_count += resource_ids.size

        if resource_ids.size > 0
          message(message_type: message_type,
                  message: message,
                  logical_resource_ids: resource_ids)

          if fatal
            exit 1
          end
        end
      end
    end
  end

  def jq_command(input_json_path, jq_expression)
    command = "cat #{input_json_path} | jq '#{jq_expression}' -e"

    Logging.logger['log'].debug command

    `#{command}`
  end
end

