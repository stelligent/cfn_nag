# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SecretsManagerSecretKmsKeyIdRule < BooleanBaseRule
  def rule_text
    'Secrets Manager Secret should explicitly specify KmsKeyId'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F81'
  end

  def resource_type
    'AWS::SecretsManager::Secret'
  end

  def boolean_property
    :kmsKeyId
  end
end
