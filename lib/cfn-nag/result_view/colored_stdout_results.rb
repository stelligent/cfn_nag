# frozen_string_literal: true

require 'cfn-nag/violation'

# Print results to STDOUT with ANSI color codes
class ColoredStdoutResults < StdoutResults
  private

  def message(message_type:,
              color:,
              message:,
              logical_resource_ids: nil,
              line_numbers: [])

    logical_resource_ids = nil if logical_resource_ids == []

    60.times { print '-' }
    puts
    puts colorize(color, "| #{message_type.upcase}")
    puts colorize(color, '|')
    puts colorize(color, "| Resources: #{logical_resource_ids}") unless logical_resource_ids.nil?
    puts colorize(color, "| Line Numbers: #{line_numbers}") unless line_numbers.empty?
    puts colorize(color, '|') unless line_numbers.empty? && logical_resource_ids.nil?
    puts colorize(color, "| #{message}")
  end

  def color_code(color_symbol)
    case color_symbol
    when :red
      31
    when :yellow
      33
    else
      0
    end
  end

  def colorize(color_symbol, str)
    "\e[#{color_code(color_symbol)}m#{str}\e[0m"
  end
end
