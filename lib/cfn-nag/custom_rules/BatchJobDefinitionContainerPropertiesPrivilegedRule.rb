# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class BatchJobDefinitionContainerPropertiesPrivilegedRule < BaseRule
  def rule_text
    'Batch Job Definition Container Properties should not have Privileged set to true'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W34'
  end

  def audit_impl(cfn_model)
    violating_job_definitions = cfn_model.resources_by_type('AWS::Batch::JobDefinition')
                                         .select do |job_definition|
      if job_definition.containerProperties
        truthy?(job_definition.containerProperties['Privileged'])
      else
        false
      end
    end

    violating_job_definitions.map(&:logical_resource_id)
  end
end
