# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'missing_property_base_rule'

class SageMakerNotebookInstanceKmsKeyIdRule < MissingPropertyBaseRule
  def rule_text
    'SageMaker NotebookInstance must have a KmsKeyId property set.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W1201'
  end

  def resource_type
    'AWS::SageMaker::NotebookInstance'
  end

  def property_name
    :kmsKeyId
  end
end
