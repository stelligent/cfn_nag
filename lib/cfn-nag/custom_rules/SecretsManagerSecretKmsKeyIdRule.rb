# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SecretsManagerSecretKmsKeyIdRule < BooleanBaseRule
  def rule_text
    'Secrets Manager Secret should explicitly specify KmsKeyId.' \
    ' Besides control of the key this will allow the secret to be shared cross-account'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W77'
  end

  def resource_type
    'AWS::SecretsManager::Secret'
  end

  def boolean_property
    :kmsKeyId
  end
end
