# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class RedshiftClusterMasterUserPasswordRule < PasswordBaseRule
  def rule_text
    'Redshift Cluster master user password must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F35'
  end

  def resource_type
    'AWS::Redshift::Cluster'
  end

  def password_property
    :masterUserPassword
  end
end
