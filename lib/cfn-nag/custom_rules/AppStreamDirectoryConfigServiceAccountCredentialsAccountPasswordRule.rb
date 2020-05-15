# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class AppStreamDirectoryConfigServiceAccountCredentialsAccountPasswordRule < PasswordBaseRule
  def rule_text
    'AppStream DirectoryConfig ServiceAccountCredentials AccountPassword ' \
    'must not be a plaintext string or a Ref to a Parameter ' \
    'with a Default value.  ' \
    'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F53'
  end

  def resource_type
    'AWS::AppStream::DirectoryConfig'
  end

  def password_property
    :serviceAccountCredentials
  end

  def sub_property_name
    'AccountPassword'
  end
end
