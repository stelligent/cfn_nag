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

  def check_password_property(cfn_model, dbinstance)
    # Checks to make sure 'RdsDbInstances' property has the key 'Password' defined.
    # Also check if the value for the 'Password' key is nil
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

  def check_dbinstance_property(dbinstance_property)
    # Checks to see if the 'RdsDbInstances' property that is part of the 'AWS::OpsWorks::Stack'
    # resource exists and is defined.
    !dbinstance_property.nil?
  end

  def get_violating_dbinstances(cfn_model, resource)
    # If the 'RdsDbInstances' property is defined then grab the violating DB Instances
    # that are part of the 'RdsDbInstances' property list.
    if check_dbinstance_property(resource.rdsDbInstances)
      violating_dbinstances = resource.rdsDbInstances.select do |dbinstance|
        check_password_property(cfn_model, dbinstance)
      end
      !violating_dbinstances.empty?
    else
      false
    end
  end 

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::OpsWorks::Stack')
    violating_resources = resources.select do |resource|
      get_violating_dbinstances(cfn_model, resource)
    end
    violating_resources.map(&:logical_resource_id)
  end
end 
