# frozen_string_literal: true

# Create array of wildcard patterns for a given string

def wildcard_patterns(string, patterns: %w[front back both])
  results = [string]
  patterns.each do |pattern|
    case pattern
    when 'front'
      results += wildcard_front(string)
    when 'back'
      results += wildcard_back(string)
    when 'both'
      results += wildcard_front_back(string)
    else
      raise "no pattern: #{pattern}. Use one or more of: front, back, both"
    end
  end
  results + ['*']
end

private

def wildcard_back(string, results = [], prepend: '')
  return results if string.empty?

  results << "#{prepend}#{string}*"
  wildcard_back(string.chop, results, prepend: prepend)
end

def wildcard_front(string, results = [])
  return results if string.empty?

  results << "*#{string}"
  wildcard_front(string[1..-1], results)
end

def wildcard_front_back(string, results = [])
  return results if string.empty?

  results += wildcard_back(string.to_s, prepend: '*')
  wildcard_front_back(string[1..-1], results)
end
