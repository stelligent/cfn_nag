# frozen_string_literal: true

require 'cfn-nag/util/truthy'
require 'cfn-nag/violation'
require_relative 'base'

class ElasticsearchDomainNodeToNodeEncryptionOptionsRule < BaseRule
  def rule_text
    'ElasticsearchcDomain should have NodeToNodeEncryptionOptions enabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W83'
  end

  def audit_impl(cfn_model)
    violating_domains = cfn_model.resources_by_type('AWS::Elasticsearch::Domain').select do |domain|
      domain.nodeToNodeEncryptionOptions.nil? || not_truthy?(domain.nodeToNodeEncryptionOptions['Enabled'])
    end

    violating_domains.map(&:logical_resource_id)
  end
end
