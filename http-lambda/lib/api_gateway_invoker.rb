require 'cfn-nag'
require 'json'

class ApiGatewayInvoker
  def audit
    cloudformation_string = lambda_inputs['body']
    cfn_nag = CfnNag.new

    audit_result = cfn_nag.audit cloudformation_string: cloudformation_string

    $lambdaLogger.log "audit_result: #{audit_result}"

    {
      statusCode: audit_result[:failure_count] > 0 ? 424 : 200,
      body: JSON.pretty_generate(audit_result)
    }
  end

  def lambda_inputs
    $lambdaInputMap
  end
end
