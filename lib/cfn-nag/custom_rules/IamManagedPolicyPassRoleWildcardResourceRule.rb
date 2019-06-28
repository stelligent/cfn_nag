# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'passrole_base_rule'

class IamManagedPolicyPassRoleWildcardResourceRule < PassRoleBaseRule
  def rule_text
    'IAM managed policy should not allow a * resource with PassRole action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F40'
  end

  def policy_type
    'AWS::IAM::ManagedPolicy'
  end
end
