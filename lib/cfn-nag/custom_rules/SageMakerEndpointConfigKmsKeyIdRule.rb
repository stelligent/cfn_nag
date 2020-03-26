# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SageMakerEndpointConfigKmsKeyIdRule < BooleanBaseRule
  def rule_text
    'SageMaker EndpointConfig should have a KmsKeyId property set.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W1200'
  end

  def resource_type
    'AWS::SageMaker::EndpointConfig'
  end

  def boolean_property
    :kmsKeyId
  end
end
