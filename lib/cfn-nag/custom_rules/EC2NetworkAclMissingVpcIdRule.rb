# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EC2NetworkAclMissingVpcIdRule < BaseRule
  def rule_text
    'VpcId parameter is missing for EC2 NetworkACL and must be set'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F78'
  end

  def audit_impl(cfn_model)
    violating_network_acls = cfn_model.resources_by_type('AWS::EC2::NetworkAcl')
                                      .select do |network_acl|
      network_acl.vpcId.nil?
    end

    violating_network_acls.map(&:logical_resource_id)
  end
end
