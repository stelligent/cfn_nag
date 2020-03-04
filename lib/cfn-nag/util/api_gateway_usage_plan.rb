# frozen_string_literal: true

# This method is used for retrieving an array:
# 1. One array for the list of AWS::ApiGateway::Stage resources that are referenced within any/all
# AWS::ApiGateway::UsagePlan resources within the CloudFormation Template
# Returns: usage_plan_stage_refs
def usage_plan_stages_and_api_refs(cfn_model)
  usage_plan_stage_refs = []
  cfn_model.resources_by_type('AWS::ApiGateway::UsagePlan').select do |usage_plan|
    next if usage_plan.apiStages.nil?

    usage_plan.apiStages.select do |api_stage|
      usage_plan_stage_refs(api_stage, usage_plan_stage_refs)
    end
  end
  usage_plan_stage_refs
end

def usage_plan_stage_refs(api_stage, usage_plan_stages)
  if api_stage['Stage'].is_a?(Hash) && api_stage['Stage'].key?('Ref')
    # If the Stage Ref is a Parameter, it is not getting subbed here correctly if there is a Default value for the param
    # This is why I added the method `add_param_values` back in the rule file to add the subbed values into the
    # `usage_plan_stages` array
    usage_plan_stages.push(api_stage['Stage']['Ref'])
  else
    usage_plan_stages.push(api_stage['Stage'])
  end
end
