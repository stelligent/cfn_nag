# frozen_string_literal: true

# Find all pemutations of an IAM string with wildcards approprate to the location

def iam_permutations(string, element, prefix = '', suffix = '')
  case element
  when 'action'
    wildcard_before_after(string, prefix, suffix) +
      wildcard_before(string, prefix, suffix) +
      wildcard_after(string, prefix, suffix) +
      ["#{prefix}#{string}#{suffix}", '*']
  end
end

private

def wildcard_before_after(string, prefix, suffix)
  results = []
  length = string.length

  (0..length).each do |loop1|
    (loop1..length).each do |loop2|
      substring = string[loop1..loop2]
      results << "#{prefix}*#{substring}*#{suffix}"
    end
  end
  results.uniq
end

def wildcard_before(string, prefix, suffix)
  results = []
  length = string.length

  (0..length).each do |loop1|
    substring = string[loop1..length]
    results << "#{prefix}*#{substring}#{suffix}"
  end
  results
end

def wildcard_after(string, prefix, suffix)
  results = []
  length = string.length

  (0..length).each do |loop1|
    substring = string[0..loop1]
    results << "#{prefix}#{substring}*#{suffix}"
  end
  results
end
