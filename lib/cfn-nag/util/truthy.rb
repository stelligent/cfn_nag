# frozen_string_literal: true

# Checks a string for truthiness. Any cased 'true' will evaluate to a true boolean.
# Any other string _at all_ results in false.
def truthy?(string)
  string.to_s.casecmp('true').zero?
end

def not_truthy?(string)
  string.nil? || string.to_s.casecmp('false').zero?
end
