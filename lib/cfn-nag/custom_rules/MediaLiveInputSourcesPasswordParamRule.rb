# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule_sub_property_with_list'

class MediaLiveInputSourcesPasswordParamRule < PasswordBaseRuleSubPropertyWithList
  def rule_text
    'MediaLive Input Sources PasswordParam must not be a plaintext ' \
    'string or a Ref to a NoEcho Parameter with a Default value.' \
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F72'
  end

  def resource_type
    'AWS::MediaLive::Input'
  end

  def password_property
    :sources
  end

  def sub_property_name
    'PasswordParam'
  end
end
