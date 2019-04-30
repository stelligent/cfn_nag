# frozen_string_literal: true

require 'cfn-nag/util/truthy.rb'

# Migrated from multiple classes, with some modifications
# Returns true if the provided key_to_check is a no-echo parameter
# without a default value; false otherwise.
def no_echo_parameter_without_default?(cfn_model, key_to_check)
  if key_to_check.is_a? Hash
    if key_to_check.key? 'Ref'
      if cfn_model.parameters.key? key_to_check['Ref']
        parameter = cfn_model.parameters[key_to_check['Ref']]

        return truthy?(parameter.noEcho) && parameter.default.nil?
      else
        return false
      end
    else
      return false
    end
  end
  # String or anything weird will fall through here
  false
end
