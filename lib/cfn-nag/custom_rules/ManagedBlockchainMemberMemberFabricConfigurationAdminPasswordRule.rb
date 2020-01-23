# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule < BaseRule
  def rule_text
    'ManagedBlockchain Member MemberFabricConfiguration AdminPasswordRule must ' \
    'not be a plaintext string or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F71'
  end

  def audit_impl(cfn_model)
    managed_blockchain_members = cfn_model.resources_by_type('AWS::ManagedBlockchain::Member')
    violating_managed_blockchains = managed_blockchain_members.select do |member|
      if password_property_does_not_exist(member)
        false
      else
        pw = member.memberConfiguration['MemberFrameworkConfiguration']['MemberFabricConfiguration']['AdminPassword']
        insecure_parameter?(cfn_model, pw) ||
          insecure_string_or_dynamic_reference?(cfn_model, pw)
      end
    end

    violating_managed_blockchains.map(&:logical_resource_id)
  end

  private

  # Checks to see if these properties are present as they are optional
  # properties for the 'AWS::ManagedBlockchain::Member' resource:
  #   'MemberFrameworkConfiguration'
  #   'MemberFabricConfiguration'
  #   'AdminPassword'
  def password_property_does_not_exist(member)
    if member.memberConfiguration['MemberFrameworkConfiguration'].nil?
      true
    elsif member.memberConfiguration['MemberFrameworkConfiguration']['MemberFabricConfiguration'].nil?
      true
    elsif member.memberConfiguration['MemberFrameworkConfiguration']['MemberFabricConfiguration']['AdminPassword'].nil?
      true
    else
      false
    end
  end
end
