# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class OpsWorksAppSslConfigurationPrivateKeyRule < PasswordBaseRule
  def rule_text
    'OpsWorks App SslConfiguration PrivateKey must not be a plaintext ' \
    'string or a Ref to a NoEcho Parameter with a Default value.' \
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F61'
  end

  def resource_type
    'AWS::OpsWorks::App'
  end

  def password_property
    :sslConfiguration
  end

  def sub_property_name
    'PrivateKey'
  end
end
