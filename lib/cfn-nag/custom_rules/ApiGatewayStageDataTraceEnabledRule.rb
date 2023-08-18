require 'cfn-nag/violation'
require_relative 'sub_property_with_list_truthy_value_base_rule'

# Checks for truthy (boolean true) 'MethodSettings.DataTraceEnabled' property
# Setting this value to true may unintentionally expose sensitive data in logs

class ApiGatewayStageDataTraceEnabledRule < SubPropertyWithListTruthyValueBaseRule
  def rule_text
    'AWS::ApiGateway::Stage should set DataTraceEnabled to false.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'CW4200'
  end

  def resource_type
    'AWS::ApiGateway::Stage'
  end

  def sublist_property
    :methodSettings
  end

  def sub_property_name
    'DataTraceEnabled'
  end

end
