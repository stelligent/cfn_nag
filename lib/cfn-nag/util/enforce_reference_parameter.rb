# frozen_string_literal: true

require 'cfn-nag/util/truthy.rb'

# Returns false if the provided key_to_check is a no-echo parameter
# without a default value; true otherwise.
# Only applicable for a hash
def insecure_parameter?(cfn_model, key_to_check)
  return false unless key_to_check.is_a? Hash
  return false unless key_to_check.key? 'Ref'

  if cfn_model.parameters.key? key_to_check['Ref']
    parameter = cfn_model.parameters[key_to_check['Ref']]
    if truthy?(parameter.noEcho) && parameter.default.nil?
      return false
    end
  end

  true
end
