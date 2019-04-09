# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

# Rule class to ensure a CF distribution has logging
class CloudFrontDistributionAccessLoggingRule < BaseRule
  def rule_text
    'CloudFront Distribution should enable access logging'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W10'
  end

  def audit_impl(cfn_model)
    violating_distributions = cfn_model.resources_by_type('AWS::CloudFront::Distribution')
                                       .select do |distribution|
      distribution.distributionConfig['Logging'].nil?
    end

    violating_distributions.map(&:logical_resource_id)
  end
end
