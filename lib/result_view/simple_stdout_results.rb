require 'rule'

class SimpleStdoutResults

  def render(results)
    results.each do |result|
      (1..60).each { print '-' }
      puts "\n" + result[:filename]
      (1..60).each { print '-' }

      result[:file_results][:violations].each do |violation|
        message message_type: violation.type,
                message: violation.message,
                logical_resource_ids: violation.logical_resource_ids,
                violating_code: violation.violating_code
      end
      puts "\nViolations count: #{Rule::count_failures(result[:file_results][:violations])}"
      puts "Warnings count: #{Rule::count_warnings(result[:file_results][:violations])}"
    end
  end

  private

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

  def indent_multiline_string_with_prefix(prefix, multiline_string)
    prefix + ' ' + multiline_string.gsub(/\n/, "\n#{prefix} ")
  end
end