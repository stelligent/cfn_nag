# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class KinesisFirehoseDeliveryStreamSplunkDestinationConfigurationHECTokenRule < PasswordBaseRule
  def rule_text
    'Kinesis Firehose DeliveryStream SplunkDestinationConfiguration HECToken ' \
    'must not be a plaintext string or a Ref to a Parameter with a ' \
    'Default value.  ' \
    'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F68'
  end

  def resource_type
    'AWS::KinesisFirehose::DeliveryStream'
  end

  def password_property
    :splunkDestinationConfiguration
  end

  def sub_property_name
    'HECToken'
  end
end
