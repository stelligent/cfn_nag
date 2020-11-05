# frozen_string_literal: true

# Returns false if the provided key_to_check is a dynamic reference
# to SSM Secure or Secrets Manager; true otherwise.
# Only applicable for a string
def insecure_string_or_dynamic_reference?(_cfn_model, key_to_check)
  # We only want to perform the check agains a string
  return false unless key_to_check.is_a? String

  # Check if string starts with a Dynamic Reference pointing to SecretsManager
  # or SSM Secure
  # &&
  # Verify that the secure string ends properly with the double curly braces
  if key_to_check.start_with?(
    '{{resolve:secretsmanager:',
    '{{resolve:ssm-secure:'
  ) && key_to_check.end_with?('}}')
    return false
  end

  # Return true if key_to_check is a string and is not calling a secured
  # dynamic reference pattern (Secrets Manager or SSM-Secure)
  true
end
