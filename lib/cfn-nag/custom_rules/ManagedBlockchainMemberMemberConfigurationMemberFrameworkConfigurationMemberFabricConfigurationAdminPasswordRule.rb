# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class ManagedBlockchainMemberMemberConfigurationMemberFrameworkConfigurationMemberFabricConfigurationAdminPasswordRule < PasswordBaseRule
  def rule_text
    'ManagedBlockchain Member MemberConfiguration MemberFrameworkConfiguration ' \
    'MemberFabricConfiguration AdminPasswordRule must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F71'
  end

  def resource_type
    'AWS::ManagedBlockchain::Member'
  end

  def password_property
    :memberConfiguration
  end

  def sub_property_name
    'MemberFrameworkConfiguration'
  end

  def sub_sub_property_name
    'MemberFabricConfiguration'
  end

  def sub_sub_sub_property_name
    'AdminPassword'
  end
end
