# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElasticsearchDomainInsideVPCRule < BaseRule
  def rule_text
    'ElasticsearchcDomain should be inside vpc, should specify VPCOptions'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W90'
  end

  def audit_impl(cfn_model)
    violating_domains = cfn_model.resources_by_type('AWS::Elasticsearch::Domain').select do |domain|
      domain.vPCOptions.nil?
    end

    violating_domains.map(&:logical_resource_id)
  end
end
