require 'json'

class JsonResults
  def render(results)

    hashified_results = results.each do |result|
      result[:file_results][:violations] = result[:file_results][:violations].map { |violation| violation.to_h }
    end

    puts JSON.pretty_generate(hashified_results)
  end
end