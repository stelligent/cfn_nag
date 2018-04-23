require 'cfn-nag/violation'

# Render plaintext results
class PlainTextResults
  def render(audit_results)
    @results = ''
    audit_results.each do |audit_result|
      present_results audit_result[:name]
      newline

      violations = audit_result[:audit_result][:violations]
      message_violations violations
      add_failures_warnings violations
    end
    @results
  end

  private

  # "Present" results between horizontal lines
  def present_results(results)
    dash_separator
    add_results results
    dash_separator
  end

  # Add failures/warnings to output
  def add_failures_warnings(violations)
    add_results "Failures count: #{Violation.count_failures(violations)}"
    add_results "Warnings count: #{Violation.count_warnings(violations)}"
  end

  # Add a string to the output, followed by newline
  def add_results(result_string)
    @results += result_string
    newline
  end

  # Add a string with | prepended on left
  def add_fancy_results(result_string)
    add_results "| #{result_string}"
  end

  # Send a message for each violation
  def message_violations(violations)
    violations.each do |violation|
      message message_type: "#{violation.type} #{violation.id}",
              message: violation.message,
              logical_resource_ids: violation.logical_resource_ids
      newline
    end
  end

  # Add a horizontal line to output, followed by newline
  def dash_separator
    60.times { @results += '-' }
    newline
  end

  # Add a newline to output
  def newline
    @results += nl
  end

  # Add a newline with | prepended to output
  def fancy_newline
    @results += '|'
    newline
  end

  def message(message_type:,
              message:,
              logical_resource_ids: nil)

    dash_separator
    add_fancy_results message_type.upcase
    fancy_newline
    if logical_resource_ids
      add_fancy_results("Resources: #{logical_resource_ids}")
      fancy_newline
    end
    add_fancy_results message.to_s
  end

  def nl
    "\n"
  end
end
