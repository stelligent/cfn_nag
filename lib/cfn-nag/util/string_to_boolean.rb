# frozen_string_literal: true

# Migrated from multiple classes with no modifications.
# I, @byronic, worry that this function isn't _quite_ what it says on the tin
def to_boolean(string)
  string.to_s.casecmp('true').zero?
end
