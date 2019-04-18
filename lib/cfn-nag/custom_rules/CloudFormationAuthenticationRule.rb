# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class CloudFormationAuthenticationRule < BaseRule
  def rule_text
    'Specifying credentials in the template itself is probably not the safest thing'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W1'
  end

  def audit_impl(cfn_model)
    violating_resources = cfn_model.raw_model['Resources'].select do |_resource_name, resource|
      resource_has_authentication?(resource) && resource_has_sensitive_credentials?(resource)
    end
    violating_resources.keys
  end

  private

  def resource_has_sensitive_credentials?(resource)
    resource['Metadata']['AWS::CloudFormation::Authentication'].find do |_auth_name, auth|
      potentially_sensitive_credentials? auth
    end
  end

  def resource_has_authentication?(resource)
    resource['Metadata'] && resource['Metadata']['AWS::CloudFormation::Authentication']
  end

  def potentially_sensitive_credentials?(auth)
    auth['accessKeyId'] || auth['password'] || auth['secretKey']
  end
end
