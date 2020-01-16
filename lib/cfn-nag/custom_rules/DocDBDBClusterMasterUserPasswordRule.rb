# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class DocDBDBClusterMasterUserPasswordRule < PasswordBaseRule
  def rule_text
    'DocDB DB Cluster master user password must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F70'
  end

  def resource_type
    'AWS::DocDB::DBCluster'
  end

  def password_property
    :masterUserPassword
  end
end
