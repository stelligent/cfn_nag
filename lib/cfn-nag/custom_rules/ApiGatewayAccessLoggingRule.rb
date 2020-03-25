# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayAccessLoggingRule < BaseRule
  def rule_text
    'ApiGateway Deployment resource should have AccessLogSetting property configured when creating an ' \
    'API Stage itself (through specifying the StageName and StageDescription properties).'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W45'
  end

  def audit_impl(cfn_model)
    stage_deployment_ids = stage_deployments_with_logging(cfn_model)

    violating_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Deployment').select do |deployment|
      violating_deployment?(deployment, stage_deployment_ids)
    end

    violating_deployments.map(&:logical_resource_id)
  end

  private

  def violating_deployment?(deployment, stage_deployment_ids)
    if deployment.stageDescription.nil?
      !stage_deployment_ids.include?(deployment.logical_resource_id)
    else
      deployment.stageDescription['AccessLogSetting'].nil?
    end
  end

  def stage_deployments_with_logging(cfn_model)
    stage_deployment_ids = []
    cfn_model.resources_by_type('AWS::ApiGateway::Stage').each do |stage|
      unless stage.accessLogSetting.nil? && stage.deploymentId.nil?
        stage_deployment_ids.push(References.resolve_resource_id(stage.deploymentId))
      end
    end
    stage_deployment_ids
  end
end
