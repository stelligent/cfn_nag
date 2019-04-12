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
    logical_resource_ids = []
    cfn_model.raw_model['Resources'].each do |resource_name, resource|
      unless resource['Metadata'].nil?
        unless resource['Metadata']['AWS::CloudFormation::Authentication'].nil?

          resource['Metadata']['AWS::CloudFormation::Authentication'].each do |_auth_name, auth|
            if potentially_sensitive_credentials? auth
              logical_resource_ids << resource_name
            end
          end

        end
      end
    end
    logical_resource_ids
  end

  def potentially_sensitive_credentials?(auth)
    auth['accessKeyId'] || auth['password'] || auth['secretKey']
  end
end
