# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

# cfn_nag rules related to RDS Instance master username
class RDSInstanceMasterUsernameRule < BaseRule
  def rule_text
    'RDS instance master username must be Ref to NoEcho Parameter. Default credentials are not recommended'
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
    if string.to_s.casecmp('true').zero?
      true
    else
      false
    end
  end

  def references_no_echo_parameter_without_default?(cfn_model, master_username)
    return false unless master_username.is_a? Hash
    return false unless master_username.key? 'Ref'
    return false unless cfn_model.parameters.key? master_username['Ref']

    parameter = cfn_model.parameters[master_username['Ref']]
    to_boolean(parameter.noEcho) && parameter.default.nil?
  end
end
