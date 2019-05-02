# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_noecho_parameter'
require_relative 'base'

# Rule class to fail on DirectoryService::SimpleAD password in template
class DirectoryServiceSimpleADPasswordRule < BaseRule
  def rule_text
    'DirectoryService::SimpleAD should use a parameter for password, with NoEcho'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F31'
  end

  def audit_impl(cfn_model)
    violating_ad = cfn_model.resources_by_type('AWS::DirectoryService::SimpleAD')
                            .select do |ad|
      if ad.password.nil?
        false
      else
        !no_echo_parameter_without_default?(cfn_model,
                                            ad.password)
      end
    end
    violating_ad.map(&:logical_resource_id)
  end
end
