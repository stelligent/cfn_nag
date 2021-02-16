# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayCacheEncryptedRule < BaseRule
  def rule_text
    'ApiGateway Deployment should have cache data encryption enabled when caching is enabled' \
    ' in StageDescription properties'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W87'
  end

  def audit_impl(cfn_model)
    violating_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Deployment').select do |deployment|
      violating_deployment?(deployment)
    end

    violating_deployments.map(&:logical_resource_id)
  end

  private

  def violating_deployment?(deployment)
    !deployment.stageDescription.nil? && truthy?(deployment.stageDescription['CachingEnabled']) \
    && !truthy?(deployment.stageDescription['CacheDataEncrypted'])
  end
end
