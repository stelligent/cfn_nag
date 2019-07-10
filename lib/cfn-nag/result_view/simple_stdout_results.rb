# frozen_string_literal: true

require 'cfn-nag/violation'

# Print results to STDOUT
class SimpleStdoutResults < StdoutResults
  private

  # rubocop:disable Lint/UnusedMethodArgument
  def message(message_type:,
              message:,
              color:,
              logical_resource_ids: nil,
              line_numbers: [])

    logical_resource_ids = nil if logical_resource_ids == []

    60.times { print '-' }
    puts
    puts "| #{message_type.upcase}"
    puts '|'
    puts "| Resources: #{logical_resource_ids}" unless logical_resource_ids.nil?
    puts "| Line Numbers: #{line_numbers}" unless line_numbers.empty?
    puts '|' unless line_numbers.empty? && logical_resource_ids.nil?
    puts "| #{message}"
  end
  # rubocop:enable Lint/UnusedMethodArgument
end
