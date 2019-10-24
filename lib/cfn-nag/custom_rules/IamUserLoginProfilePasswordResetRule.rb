# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamUserLoginProfilePasswordResetRule < BaseRule
	def rule_text
		'IAM User Login Profile should exist and have PasswordResetRequired set to true'
	end

	def rule_type
		Violation::WARNING
	end

	def rule_id
		'W50'
	end

	def audit_impl(cfn_model)
		violating_iam_users = cfn_model.resources_by_type('AWS::IAM::User').select do |iam_user|
			iam_user.loginProfile['PasswordResetRequired'].nil? || iam_user.loginProfile['PasswordResetRequired'].to_s == 'false'
		end
		
		violating_iam_users.map(&:logical_resource_id)
	end
end
