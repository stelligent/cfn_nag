# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'passrole_base_rule'

class IamPolicyPassRoleWildcardResourceRule < PassRoleBaseRule
  def rule_text
    'IAM policy should not allow * resource with PassRole action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F39'
  end

  def policy_type
    'AWS::IAM::Policy'
  end
end
