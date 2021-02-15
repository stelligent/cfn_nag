# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KinesisFirehoseDeliveryStreamEncryptionRule < BaseRule
  def rule_text
    'Kinesis Firehose DeliveryStream of type DirectPut should specify SSE.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W88'
  end

  def audit_impl(cfn_model)
    violating_delivery_streams =
      cfn_model.resources_by_type('AWS::KinesisFirehose::DeliveryStream').select do |delivery_stream|
        violating_delivery_stream?(delivery_stream)
      end

    violating_delivery_streams.map(&:logical_resource_id)
  end

  private

  def violating_delivery_stream?(delivery_stream)
    if delivery_stream.deliveryStreamType == 'KinesisStreamAsSource'
      false
    elsif delivery_stream.deliveryStreamEncryptionConfigurationInput.nil?
      true
    else
      delivery_stream.deliveryStreamEncryptionConfigurationInput['KeyType'].nil?
    end
  end
end
