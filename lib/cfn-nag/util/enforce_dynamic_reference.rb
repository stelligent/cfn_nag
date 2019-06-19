# frozen_string_literal: true

# Returns false if the provided key_to_check is a dynamic reference
# to SSM Secure or Secrets Manager; true otherwise.
# Only applicable for a string
def insecure_dynamic_reference?(_cfn_model, key_to_check)
  return false unless key_to_check.is_a? String

  if key_to_check.start_with?('{{resolve:secretsmanager:', '{{resolve:ssm-secure:')
    if key_to_check.end_with? '}}'
      return false
    end
  end

  true
end
