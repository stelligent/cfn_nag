# frozen_string_literal: true

require 'cfn-nag/violation'
require 'colorize'

# Print results to STDOUT
class ColoredStdoutResults < StdoutResults

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
end
