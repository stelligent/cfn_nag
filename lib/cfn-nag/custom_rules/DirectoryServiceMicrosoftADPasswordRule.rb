# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

# Rule class to fail on DirectoryService::MicrosoftAD password in template
class DirectoryServiceMicrosoftADPasswordRule < BaseRule
  def rule_text
    'DirectoryService::MicrosoftAD password must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F36'
  end

  def audit_impl(cfn_model)
    violating_ad = cfn_model.resources_by_type('AWS::DirectoryService::MicrosoftAD')
                            .select do |ad|
      if ad.password.nil?
        false
      else
        insecure_parameter?(cfn_model, ad.password) ||
          insecure_string_or_dynamic_reference?(cfn_model, ad.password)
      end
    end
    violating_ad.map(&:logical_resource_id)
  end
end
