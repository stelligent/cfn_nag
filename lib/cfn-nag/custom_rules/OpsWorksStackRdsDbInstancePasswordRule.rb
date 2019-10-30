# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class OpsWorksStackRdsDbInstancePasswordRule < BaseRule

  def rule_text
    'OpsWorks Stack RDS DBInstance Password property should not show password in plain text, resolve an unsecure ssm string, or have a default value for parameter.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F54'
  end

  def resource_type
    'AWS::OpsWorks::Stack'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::OpsWorks::Stack')

    violating_resources = resources.select do |resource|
      violating_db_instances = resource.rdsDbInstances.select do |dbinstance|
        insecure_parameter?(cfn_model, dbinstance['DbPassword']) || \
        insecure_string_or_dynamic_reference?(cfn_model, dbinstance['DbPassword']) || \
        dbinstance['DbPassword'].nil?
      end
      !violating_db_instances.empty?
    end

    violating_resources.map(&:logical_resource_id)
  end
end 

