# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class OpsWorksStackRdsDbInstancePasswordRule < BaseRule

  def rule_text
    'OpsWorks Stack RDS DBInstance Password property should not show password ' +
    'in plain text, resolve an unsecure ssm string, or have a default value for parameter.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F54'
  end

  def audit_impl(cfn_model)
    opsworks_stacks = cfn_model.resources_by_type('AWS::OpsWorks::Stack')
    violating_opsworks_stacks = opsworks_stacks.select do |opsworks_stack|
      violating_db_instances?(cfn_model, opsworks_stack)
    end
    violating_opsworks_stacks.map(&:logical_resource_id)
  end

  private 

  def db_instance_has_insecure_password?(cfn_model, dbinstance)
    if dbinstance.has_key? 'DbPassword'
      if insecure_parameter?(cfn_model, dbinstance['DbPassword'])
        true
      elsif insecure_string_or_dynamic_reference?(cfn_model, dbinstance['DbPassword'])
        true
      elsif dbinstance['DbPassword'].nil?
        true
      end
    else
      true    
    end
  end

  def violating_db_instances?(cfn_model, opsworks_stack)
    if !opsworks_stack.rdsDbInstances.nil?
      violating_dbinstances = opsworks_stack.rdsDbInstances.select do |dbinstance|
        db_instance_has_insecure_password?(cfn_model, dbinstance)
      end
      !violating_dbinstances.empty?
    else
      false
    end
  end 
end 
