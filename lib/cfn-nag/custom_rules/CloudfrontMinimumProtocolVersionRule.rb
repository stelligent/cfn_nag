# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class CloudfrontMinimumProtocolVersionRule < BaseRule
  def rule_text
    'Cloudfront should use minimum protocol version TLS 1.2'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W70'
  end

  def audit_impl(cfn_model)
    violating_distributions = cfn_model.resources_by_type('AWS::CloudFront::Distribution')
                                       .select do |distribution|
      distribution.distributionConfig['ViewerCertificate'].nil? || distribution.distributionConfig['ViewerCertificate']['MinimumProtocolVersion'].nil? || distribution.distributionConfig['ViewerCertificate']['MinimumProtocolVersion'] != 'TLSv1.2_2018' || !distribution.distributionConfig['ViewerCertificate']['CloudFrontDefaultCertificate'].nil? || distribution.distributionConfig['ViewerCertificate']['CloudFrontDefaultCertificate']
    end

    violating_distributions.map(&:logical_resource_id)
  end
end
