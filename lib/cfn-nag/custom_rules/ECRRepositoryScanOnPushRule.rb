# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class ECRRepositoryScanOnPushRule < BaseRule
  def rule_text
    'ECR Repository should have scanOnPush enabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W79'
  end

  def audit_impl(cfn_model)
    violating_ecr_registries = cfn_model.resources_by_type('AWS::ECR::Repository').select do |registry|
      registry.imageScanningConfiguration.nil? ||
        !truthy?(registry.imageScanningConfiguration['scanOnPush'].to_s)
    end

    violating_ecr_registries.map(&:logical_resource_id)
  end
end
