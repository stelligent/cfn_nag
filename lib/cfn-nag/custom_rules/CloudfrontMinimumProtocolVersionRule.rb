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
                                       .select do |dist|
      dist.distributionConfig['ViewerCertificate'].nil? || tls_version?(dist.distributionConfig['ViewerCertificate'])
    end

    violating_distributions.map(&:logical_resource_id)
  end

  private

  def tls_version?(viewer_certificate)
    cert_has_bad_tls_version?(viewer_certificate) || override_tls_config?(viewer_certificate)
  end

  def cert_has_bad_tls_version?(viewer_certificate)
    viewer_certificate['MinimumProtocolVersion'].nil? || viewer_certificate['MinimumProtocolVersion'] != 'TLSv1.2_2018'
  end

  def override_tls_config?(viewer_certificate)
    !viewer_certificate['CloudFrontDefaultCertificate'].nil? && viewer_certificate['CloudFrontDefaultCertificate']
  end
end
