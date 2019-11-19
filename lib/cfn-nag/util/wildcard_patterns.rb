# frozen_string_literal: true

# Create array of wildcard patterns for a given input string

def wildcard_patterns(input, pattern_types: %w[front back both])
  input_string = input.to_s
  results = [input_string]
  pattern_types.each do |pattern_type|
    case pattern_type
    when 'front'
      results += wildcard_front(input_string)
    when 'back'
      results += wildcard_back(input_string)
    when 'both'
      results += wildcard_front_back(input_string)
    else
      raise "no pattern of type: #{pattern_type}. Use one or more of: front, back, both"
    end
  end
  results + ['*']
end

private

def wildcard_back(input_string, results = [], prepend: '')
  return results if input_string.empty?

  results << "#{prepend}#{input_string}*"
  wildcard_back(input_string.chop, results, prepend: prepend)
end

def wildcard_front(input_string, results = [])
  return results if input_string.empty?

  results << "*#{input_string}"
  wildcard_front(input_string[1..-1], results)
end

def wildcard_front_back(input_string, results = [])
  return results if input_string.empty?

  results += wildcard_back(input_string, prepend: '*')
  wildcard_front_back(input_string[1..-1], results)
end
