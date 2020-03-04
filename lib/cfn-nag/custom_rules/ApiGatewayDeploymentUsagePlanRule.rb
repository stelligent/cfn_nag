# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/api_gateway_usage_plan'
require_relative 'base'

class ApiGatewayDeploymentUsagePlanRule < BaseRule
  def rule_text
    'An AWS::ApiGateway::Deployment resource that is creating an API Stage itself (This happens when you reference ' \
      'an AWS::ApiGateway::RestApi resource in the `RestApiId` property but specify a hardcoded value or Parameter ' \
      'reference in the `StageName` property. The AWS::ApiGateway::Deployment resource will then create a stage, for ' \
      'the associated Rest API, with whatever the `StageName` property value was) should also have that same API ' \
      'Stage referenced in a AWS::ApiGateway::UsagePlan resource. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W64'
  end

  def audit_impl(cfn_model)
    # I gather a list of the ApiStages that are within every UsagePlan resource
    usage_plan_stages = usage_plan_stages_and_api_refs(cfn_model)

    # I gather a list of all AWS::ApiGateway::Stage resources
    api_stage_resources = get_api_stage_resources(cfn_model)
    add_param_values(cfn_model, usage_plan_stages)

    # cfn_model.resources_by_type('AWS::ApiGateway::UsagePlan').select do |usage_plan|
    #   puts usage_plan.apiStages
    # end

    # This array contains the Parameter names that are getting referenced within UsagePlan > ApiStage > [{ApiId: blah, Stage: !Ref Parameter_Name}]
    # because the method `usage_plan_stages_and_api_refs(cfn_model)` is not substituting the ref'd params properly (see method)
    puts usage_plan_stages
    violating_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Deployment').select do |deployment|
      violating_deployments?(usage_plan_stages, deployment, api_stage_resources)
    end

    violating_deployments.map(&:logical_resource_id)
  end

  private

  def get_api_stage_resources(cfn_model)
    api_stage_resources = []
    cfn_model.resources_by_type('AWS::ApiGateway::Stage').select do |api_stage|
      api_stage_resources.push(api_stage.logical_resource_id)
    end
    api_stage_resources
  end

  def add_param_values(cfn_model, usage_plan_stages)
    usage_plan_stages.select do |up_stage|
      if cfn_model.parameters.key?(up_stage)
        # Use
        usage_plan_stages.push(cfn_model.parameters[up_stage].synthesized_value)
      end
    end
  end

  def violating_deployments?(usage_plan_stages, deployment, api_stage_resources)
    if deployment.stageName.is_a?(Hash) && deployment.stageName.key?('Ref')
      unless api_stage_resources.include?(deployment.stageName['Ref'])
        !usage_plan_stages.include?(deployment.stageName['Ref'])
      end
    else
      !usage_plan_stages.include?(deployment.stageName)
    end
  end
end
