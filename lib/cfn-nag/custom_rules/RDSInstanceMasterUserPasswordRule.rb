require 'cfn-nag/violation'
require_relative 'base'

class RDSInstanceMasterUserPasswordRule < BaseRule
  def rule_text
    'RDS instance master user password must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F23'
  end

  # one word of warning... if somebody applies parameter values via JSON....
  # this will compare that....
  # probably shouldn't be doing that though if it's NoEcho there's a good reason
  # bother checking synthesized_value? that would be the indicator.....
  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::RDS::DBInstance')
    violating_rdsinstances = resources.select do |instance|
      if instance.masterUserPassword.nil?
        false
      else
        !no_echo_parameter_without_default?(cfn_model,
                                            instance.masterUserPassword)
      end
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end

  private

  def to_boolean(string)
    string.to_s.casecmp('true').zero?
  end

  def no_echo_parameter_without_default?(cfn_model, master_user_password)
    # i feel like i've written this mess somewhere before
    if master_user_password.is_a? Hash
      if master_user_password.key? 'Ref'
        if cfn_model.parameters.key? master_user_password['Ref']
          parameter = cfn_model.parameters[master_user_password['Ref']]

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
