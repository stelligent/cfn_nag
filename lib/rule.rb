require 'logging'
require_relative 'violation'

module Rule
  attr_accessor :input_json

  # jq preamble to spit out Resources but as an array of key-value pairs
  # can be used in jq rule definition but... this is probably reducing replication at the cost of opaqueness
  def resources
    '.Resources|with_entries(.value.LogicalResourceId = .key)[]'
  end

  # jq to filter CloudFormation resources by Type
  # can be used in jq rule definition but... this is probably reducing replication at the cost of opaqueness
  def resources_by_type(resource)
    "#{resources}| select(.Type == \"#{resource}\")"
  end

  def warning(id:, jq:, message:)
    warning_def = @rule_registry.definition(id: id,
                                            type: Violation::WARNING,
                                            message: message)

    return if @stop_processing

    Logging.logger['log'].debug jq

    stdout = jq_command(@input_json, jq)
    result = $?.exitstatus
    scrape_jq_output_for_error(jq, stdout)

    resource_ids = parse_logical_resource_ids(stdout)
    new_warnings = resource_ids.size
    if result == 0 and new_warnings > 0
      add_violation(id: warning_def.id,
                    type: Violation::WARNING,
                    message: message,
                    logical_resource_ids: resource_ids)
    end
  end

  def raw_fatal_assertion(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: false,
                 fatal: true,
                 message: message,
                 raw: true)
  end

  def fatal_assertion(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: false,
                 fatal: true,
                 message: message)
  end

  def raw_fatal_violation(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: true,
                 fatal: true,
                 message: message,
                 raw: true)
  end

  def fatal_violation(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: true,
                 fatal: true,
                 message: message)
  end

  def violation(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: true,
                 message: message)
  end

  def assertion(id:, jq:, message:)
    failing_rule(id: id,
                 jq_expression: jq,
                 fail_if_found: false,
                 message: message)
  end

  def self.empty?(array)
    array.nil? or array.size ==0
  end

  def self.count_warnings(violations)
    violations.inject(0) do |count, violation|
      if violation.type == Violation::WARNING
        if empty?(violation.logical_resource_ids)
          count += 1
        else
          count += violation.logical_resource_ids.size
        end
      end
      count
    end
  end

  def self.count_failures(violations)
    violations.inject(0) do |count, violation|
      if violation.type == Violation::FAILING_VIOLATION
        if empty?(violation.logical_resource_ids)
          count += 1
        else
          count += violation.logical_resource_ids.size
        end
      end
      count
    end
  end

  # this is to record a violation as opposed to "registering" a violation
  #
  # not super keen on this looking at it after the fact.... @violations
  # will have to live in the object this Rule is mixed into i.e. CfnNag
  def add_violation(id:,
                    type:,
                    message:,
                    logical_resource_ids: nil,
                    violating_code: nil)
    violation = Violation.new(id: id,
                              type: type,
                              message: message,
                              logical_resource_ids: logical_resource_ids,
                              violating_code: violating_code)
    @violations << violation
  end

  private

  def parse_logical_resource_ids(stdout)
    JSON.load(stdout)
  end

  def scrape_jq_output_for_error(command, stdout)
    fail "jq rule is likely not correct: #{command}\n\n#{stdout}" if stdout.include? 'jq: error'
  end

  # fail_if_found: this is false for an assertion, true for a violation.  either way this rule ups the "failure" count
  #
  # raw: don't try to parse the output in any way.  the rule is some kind of oddball so just show what matched and up
  #      failure count by 1
  #
  # fatal: if true, any match of the rule causes immediate shutdown to avoid more complicated downstream error checking
  def failing_rule(id:,
                   jq_expression:,
                   fail_if_found:,
                   message:,
                   fatal: false,
                   raw: false)

    fail_def =  @rule_registry.definition(id: id,
                                          type: Violation::FAILING_VIOLATION,
                                          message: message)

    return if @stop_processing

    Logging.logger['log'].debug jq_expression

    stdout = jq_command(@input_json, jq_expression)
    result = $?.exitstatus
    scrape_jq_output_for_error(jq_expression, stdout)
    if (fail_if_found and result == 0) or
       (not fail_if_found and result != 0)

      if raw
        add_violation(id: fail_def.id,
                      type: Violation::FAILING_VIOLATION,
                      message: message,
                      violating_code: stdout)

        if fatal
          @stop_processing = true
        end
      else
        resource_ids = parse_logical_resource_ids(stdout)

        if resource_ids.size > 0
          add_violation(id: fail_def.id,
                        type: Violation::FAILING_VIOLATION,
                        message: message,
                        logical_resource_ids: resource_ids)

          if fatal
            @stop_processing = true
          end
        end
      end
    end
  end

  # the -e will return an exit code
  def jq_command(input_json, jq_expression)
    IO.popen(['jq', jq_expression, '-e'], 'r+', {:err=>[:child, :out]}) do |pipe|
      pipe << input_json
      pipe.close_write
      pipe.readlines.join
    end
  end
end
