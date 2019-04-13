# frozen_string_literal: true

require 'cfn-nag/violation'

# Print results to STDOUT
class SimpleStdoutResults
  def message_violations(violations)
    violations.each do |violation|
      message message_type: "#{violation.type} #{violation.id}",
              message: violation.message,
              logical_resource_ids: violation.logical_resource_ids
    end
  end

  def print_failures(violations)
    puts "\nFailures count: #{Violation.count_failures(violations)}"
  end

  def print_warnings(violations)
    puts "Warnings count: #{Violation.count_warnings(violations)}"
  end

  def render(results)
    results.each do |result|
      60.times { print '-' }
      puts "\n" + result[:filename]
      60.times { print '-' }

      violations = result[:file_results][:violations]

      message_violations violations
      print_failures violations
      print_warnings violations
    end
  end

  private

  def message(message_type:,
              message:,
              logical_resource_ids: nil)

    logical_resource_ids = nil if logical_resource_ids == []

    60.times { print '-' }
    puts
    puts "| #{message_type.upcase}"
    puts '|'
    puts "| Resources: #{logical_resource_ids}" unless logical_resource_ids.nil?
    puts '|' unless logical_resource_ids.nil?
    puts "| #{message}"
  end

  def indent_multiline_string_with_prefix(prefix, multiline_string)
    prefix + ' ' + multiline_string.gsub(/\n/, "\n#{prefix} ")
  end
end
