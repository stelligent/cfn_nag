# frozen_string_literal: true

# This method is used for retrieving two different arrays:
# 1. One array for the list of AWS::ApiGateway::Stage resources that are referenced within any/all
# AWS::ApiGateway::UsagePlan resources within the CloudFormation Template
# 2. Another array for the list of AWS::ApiGateway::RestApi resources that are referenced within any/all
# AWS::ApiGateway::UsagePlan resources within the CloudFormation Template
#
# Returns: usage_plan_stage_refs, usage_plan_api_id_refs
def usage_plan_stages_and_api_refs(cfn_model)
  usage_plan_stage_refs = []
  usage_plan_api_id_refs = []

  cfn_model.resources_by_type('AWS::ApiGateway::UsagePlan').select do |usage_plan|
    next if usage_plan.apiStages.nil?

    usage_plan.apiStages.select do |api_stage|
      usage_plan_api_refs(api_stage, usage_plan_api_id_refs)
      usage_plan_stage_refs(api_stage, usage_plan_stage_refs)
    end
  end
  [usage_plan_stage_refs, usage_plan_api_id_refs]
end

def usage_plan_api_refs(api_stage, usage_plan_apis)
  if api_stage['ApiId'].is_a?(Hash) && api_stage['ApiId'].key?('Ref')
    usage_plan_apis.push(api_stage['ApiId']['Ref'])
  end
end

def usage_plan_stage_refs(api_stage, usage_plan_stages)
  if api_stage['Stage'].is_a?(Hash) && api_stage['Stage'].key?('Ref')
    usage_plan_stages.push(api_stage['Stage']['Ref'])
  end
end
