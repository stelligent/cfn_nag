require 'cfn-nag'
require 'json'
require_relative 'clients'

class ApiGatewayInvoker
  include Clients

  def audit
    cloudformation_string = lambda_inputs['body']
    if cloudformation_string.nil?
      raise 'template_content parameter must be set with CloudFormation ' \
            'template content'
    end

    cfn_nag = CfnNag.new

    audit_result = cfn_nag.audit cloudformation_string: cloudformation_string

    $lambdaLogger.log "audit_result: #{audit_result}"

    { statusCode: audit_result['failure_count'] > 0 ? 424 : 200,
      body: JSON.generate(audit_result) }
  end

  def lambda_inputs
    $lambdaInputMap
  end
end
