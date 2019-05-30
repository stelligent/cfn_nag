# frozen_string_literal: true

require 'cfn-nag/violation'
require 'colorize'

# Print results to STDOUT
class SimpleStdoutResults
  def message_violations(violations)
    violations.each do |violation|
      color = violation.type == 'FAIL' ? :red : :yellow

      message message_type: "#{violation.type} #{violation.id}",
              color: color,
              message: violation.message,
              logical_resource_ids: violation.logical_resource_ids,
              line_numbers: violation.line_numbers
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

  # rubocop:disable Metrics/AbcSize
  def message(message_type:,
              color:,
              message:,
              logical_resource_ids: nil,
              line_numbers: [])

    logical_resource_ids = nil if logical_resource_ids == []

    60.times { print '-' }
    puts
    puts "| #{message_type.upcase}".send(color)
    puts '|'.send(color)
    puts "| Resources: #{logical_resource_ids}".send(color) unless logical_resource_ids.nil?
    puts "| Line Numbers: #{line_numbers}".send(color) unless line_numbers.empty?
    puts '|'.send(color) unless line_numbers.empty? && logical_resource_ids.nil?
    puts "| #{message}".send(color)
  end
  # rubocop:enable Metrics/AbcSize

  def indent_multiline_string_with_prefix(prefix, multiline_string)
    prefix + ' ' + multiline_string.gsub(/\n/, "\n#{prefix} ")
  end
end
