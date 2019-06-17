# frozen_string_literal: true

# Returns true if the provided key_to_check is an allowed Intrinsic Function
# for a Condition; false otherwise.
def conditional_intrinsic_func_present?(cfn_model, key_to_check)
  return false unless cfn_model.raw_model['Conditions']
  return false unless key_to_check.is_a? Hash
  return false unless [
    'Fn::And',
    'Fn::Equals',
    'Fn::If',
    'Fn::Not',
    'Fn::Or'
  ].any? do |intrinsic_func|
    key_to_check.key?(intrinsic_func)
  end

  true
end
