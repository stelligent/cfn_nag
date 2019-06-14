# frozen_string_literal: true

# Returns true if the provided key_to_check is a dynamic reference
# to SSM* or Secrets Manager; false otherwise.
def dynamic_reference_property_value?(_cfn_model, key_to_check)
  return false unless key_to_check.is_a? String
  return false unless key_to_check.start_with?('{{resolve:secretsmanager:',
                                               '{{resolve:ssm-secure:')
  return false unless key_to_check.end_with? '}}'

  true
end
