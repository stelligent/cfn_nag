# frozen_string_literal: true

require 'cfn-nag/util/truthy.rb'

# Migrated from multiple classes, with some modifications
# Returns true if the provided key_to_check is a no-echo parameter
# without a default value; false otherwise.
def secrets_manager_property_value?(_cfn_model, key_to_check)
  if key_to_check.is_a? String
    if key_to_check.start_with? '{{resolve:secretsmanager:'
      if key_to_check.end_with? '}}'
        return true
      end
    else
      return false
    end
  end
  false
end
