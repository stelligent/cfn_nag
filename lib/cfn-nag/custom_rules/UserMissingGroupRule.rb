# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class UserMissingGroupRule < BaseRule
  def rule_text
    'User is not assigned to a group'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F2000'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.iam_users.each do |iam_user|
      logical_resource_ids << iam_user.logical_resource_id if iam_user.group_names.empty?
    end

    logical_resource_ids
  end
end
