# frozen_string_literal: true

require 'cfn-nag/util/truthy'

# Returns false if the provided key_to_check is a no-echo parameter without a
# default value, or pseudo parameter reference to 'AWS::NoValue'; true otherwise.
# Only applicable for a hash
def insecure_parameter?(cfn_model, key_to_check)
  # We only want to perform the check against a hash
  return false unless key_to_check.is_a? Hash

  # We don't care if any other intrinsic function is used here. We only want to
  # verify that Ref is being used properly
  return false unless key_to_check.key? 'Ref'

  # Check if the property is a pseudo parameter reference to 'AWS::NoValue'
  return false if key_to_check['Ref'] == 'AWS::NoValue'

  # Run 'no_echo_and_no_default_parameter_check' if the key parameter is Ref
  return no_echo_and_no_default_parameter_check(cfn_model, key_to_check) if
    cfn_model.parameters.key? key_to_check['Ref']

  # Return true if key_to_check is a hash and/or a key Ref that does not have
  # the NoEcho parameter set to true and a Default parameter that is not nil
  true
end

# Returns false if the parameter is setup securely by stating NoEcho=true & Default
# is not present; otherwise returns true
def no_echo_and_no_default_parameter_check(cfn_model, key_to_check)
  parameter = cfn_model.parameters[key_to_check['Ref']]
  truthy?(parameter.noEcho) && parameter.default.nil? ? false : true
end
