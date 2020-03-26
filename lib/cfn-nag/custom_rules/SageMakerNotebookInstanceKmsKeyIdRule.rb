# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SageMakerNotebookInstanceKmsKeyIdRule < BooleanBaseRule
  def rule_text
    'SageMaker NotebookInstance should have a KmsKeyId property set.'
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

  def boolean_property
    :kmsKeyId
  end
end
