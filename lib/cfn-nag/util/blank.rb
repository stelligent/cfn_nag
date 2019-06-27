# frozen_string_literal: true

# Checks a string for being missing, empty, or only containing spaces
def blank?(str)
  str.nil? || str.to_s.strip == ''
end
