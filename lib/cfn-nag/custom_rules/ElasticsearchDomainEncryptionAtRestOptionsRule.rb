# frozen_string_literal: true

require 'cfn-nag/util/truthy'
require 'cfn-nag/violation'
require_relative 'base'

class ElasticsearchDomainEncryptionAtRestOptionsRule < BaseRule
  def rule_text
    'ElasticsearchcDomain should specify EncryptionAtRestOptions'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W54'
  end

  def audit_impl(cfn_model)
    violating_domains = cfn_model.resources_by_type('AWS::Elasticsearch::Domain').select do |domain|
      domain.encryptionAtRestOptions.nil? || not_truthy?(domain.encryptionAtRestOptions['Enabled'])
    end

    violating_domains.map(&:logical_resource_id)
  end
end
