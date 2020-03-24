# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'missing_property_base_rule'

class SageMakerEndpointConfigKmsKeyIdRule < MissingPropertyBaseRule
  def rule_text
    'SageMaker EndpointConfig must have a KmsKeyId property set.'
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

  def property_name
    :kmsKeyId
  end
end
