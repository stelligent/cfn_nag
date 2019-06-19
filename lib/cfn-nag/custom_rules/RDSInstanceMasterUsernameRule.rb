# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_dynamic_reference'
require 'cfn-nag/util/enforce_reference_parameter'
require_relative 'base'

# cfn_nag rules related to RDS Instance master username
class RDSInstanceMasterUsernameRule < BaseRule
  def rule_text
    'RDS instance master username must be Ref to NoEcho Parameter. Default ' \
    'credentials are not recommended'
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
        insecure_parameter?(cfn_model, instance.masterUsername) ||
          insecure_dynamic_reference?(cfn_model, instance.masterUsername)
      end
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end
end
