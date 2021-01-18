# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule < BaseRule
  def rule_text
    'Kendra Index ServerSideEncryptionConfiguration should specify a KmsKeyId value.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W80'
  end

  def audit_impl(cfn_model)
    violating_indices = cfn_model.resources_by_type('AWS::Kendra::Index').select do |index|
      index.serverSideEncryptionConfiguration.nil? ||
        index.serverSideEncryptionConfiguration['KmsKeyId'].nil?
    end

    violating_indices.map(&:logical_resource_id)
  end
end
