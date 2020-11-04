# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/iam_complexity_metric/spcm'
require_relative 'base'

class SPCMRule < BaseRule
  attr_accessor :spcm_threshold

  DEFAULT_THRESHOLD = 25

  def rule_text
    "SPCM for IAM policy document is higher than #{spcm_threshold || DEFAULT_THRESHOLD}"
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W76'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []
    begin
      policy_documents = SPCM.new.metric_impl(cfn_model)
    rescue StandardError => catch_all_exception
      puts "Experimental SPCM rule is failing. Please report #{catch_all_exception} with the violating template"
      policy_documents = {
        'AWS::IAM::Policy' => {},
        'AWS::IAM::Role' => {}
      }
    end

    threshold = spcm_threshold.nil? ? DEFAULT_THRESHOLD : spcm_threshold.to_i
    logical_resource_ids += violating_policy_resources(policy_documents, threshold)
    logical_resource_ids += violating_role_resources(policy_documents, threshold)

    logical_resource_ids
  end

  private

  def violating_role_resources(policy_documents, threshold)
    logical_resource_ids = []

    # unfortunately the line numbers will break if we don't return
    # the logical resource id - so there isn't a good way to communicate
    # the specific policy within the role that is offending
    policy_documents['AWS::IAM::Role'].each do |logical_resource_id, policies|
      policies.each do |_, metric|
        if metric >= threshold
          logical_resource_ids << logical_resource_id
        end
      end
    end
    logical_resource_ids
  end

  def violating_policy_resources(policy_documents, threshold)
    logical_resource_ids = []
    policy_documents['AWS::IAM::Policy'].each do |logical_resource_id, metric|
      if metric >= threshold
        logical_resource_ids << logical_resource_id
      end
    end
    logical_resource_ids
  end
end
