# frozen_string_literal: true

# Returns true if the provided key_to_check is a dynamic reference
# to Secrets Manager; false otherwise.
def secrets_manager_property_value?(_cfn_model, key_to_check)
  return false unless key_to_check.is_a? String
  return false unless key_to_check.start_with? '{{resolve:secretsmanager:'
  return false unless key_to_check.end_with? '}}'

  true
end
