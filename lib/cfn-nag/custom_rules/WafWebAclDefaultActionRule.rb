# frozen_string_literal: true

# Copy
# "MyWebACL": {
#   "Type": "AWS::WAF::WebACL",
#   "Properties": {
#     "Name": "WebACL to with three rules",
#     "DefaultAction": {
#       "Type": "ALLOW"
#     },

require 'cfn-nag/violation'
require_relative 'base'

class WafWebAclDefaultActionRule < BaseRule
  def rule_text
    'WebAcl DefaultAction should not be ALLOW'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F665'
  end

  def audit_impl(cfn_model)
    violating_web_acls = cfn_model.resources_by_type('AWS::WAF::WebACL').select do |web_acl|
      web_acl.defaultAction['Type'] == 'ALLOW'
    end

    violating_web_acls.map(&:logical_resource_id)
  end
end
