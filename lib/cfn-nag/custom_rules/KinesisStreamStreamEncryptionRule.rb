# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KinesisStreamStreamEncryptionRule < BaseRule
  def rule_text
    'Kinesis Stream should specify StreamEncryption.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W49'
  end

  def audit_impl(cfn_model)
    violating_kinesis_streams = cfn_model.resources_by_type('AWS::Kinesis::Stream').select do |kinesis_stream|
      kinesis_stream.streamEncryption.nil? || 
    end

    violating_kinesis_streams.map(&:logical_resource_id)
  end

  def violating_kinesis_streams?(kinesis_stream)
    
end