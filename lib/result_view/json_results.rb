require 'json'
class JsonResults

  def render(violations)
    violations_hashes = violations.map do |violation|
      {
        type: violation.type,
        message: violation.message,
        logical_resource_ids: violation.logical_resource_ids,
        violating_code: violation.violating_code
      }
    end
    puts JSON.pretty_generate(violations_hashes)
  end
end