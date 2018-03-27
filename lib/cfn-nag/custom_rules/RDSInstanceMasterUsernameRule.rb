require 'cfn-nag/violation'
require_relative 'base'

# cfn_nag rules related to RDS Instance master username
class RDSInstanceMasterUsernameRule < BaseRule
  def rule_text
    'RDS instance master username must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F24'
  end

  # Warning: if somebody applies parameter values via JSON, this will compare
  # that....
  # probably shouldn't be doing that though -
  # if it's NoEcho there's a good reason
  # bother checking synthesized_value? that would be the indicator.....
  def audit_impl(cfn_model)
    violating_rdsinstances = cfn_model.resources_by_type('AWS::RDS::DBInstance')
                                      .select do |instance|
      if instance.masterUsername.nil?
        false
      else
        !references_no_echo_parameter_without_default?(cfn_model,
                                                       instance.masterUsername)
      end
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end

  private

  def to_boolean(string)
    if string.to_s.downcase == 'true'
      true
    else
      false
    end
  end

  def references_no_echo_parameter_without_default?(cfn_model, master_username)
    if master_username.is_a? Hash
      if master_username.has_key? 'Ref'
        if cfn_model.parameters.has_key? master_username['Ref']
          parameter = cfn_model.parameters[master_username['Ref']]

          return to_boolean(parameter.noEcho) && parameter.default.nil?
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
end
