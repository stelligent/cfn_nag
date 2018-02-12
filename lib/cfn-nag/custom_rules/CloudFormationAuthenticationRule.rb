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
    logical_resource_ids = []
    cfn_model.raw_model['Resources'].each do |resource_name, resource|
      unless resource['Metadata'].nil?
        if !resource['Metadata']['AWS::CloudFormation::Authentication'].nil?

          resource['Metadata']['AWS::CloudFormation::Authentication'].each do |auth_name, auth|
            if !auth['accessKeyId'].nil? && !auth['password'].nil? && !auth['secretKey'].nil?
              logical_resource_ids << auth_name
            end
          end

        end
      end
    end
    logical_resource_ids
  end
end
