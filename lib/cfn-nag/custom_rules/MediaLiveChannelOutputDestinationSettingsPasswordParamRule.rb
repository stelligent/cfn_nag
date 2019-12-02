# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class MediaLiveChannelOutputDestinationSettingsPasswordParamRule < BaseRule
  def rule_text
    'MediaLive Channel OutputDestinationSettings PasswordParam must not be a ' \
    'plaintext string or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F73'
  end

  def audit_impl(cfn_model)
    media_live_channels = cfn_model.resources_by_type('AWS::MediaLive::Channel')
    violating_channels = media_live_channels.select do |channel|
      violating_destinations?(cfn_model, channel)
    end

    violating_channels.map(&:logical_resource_id)
  end

  private

  def violating_destinations?(cfn_model, channel)
    if !channel.destinations.nil?
      violating_destination = channel.destinations.select do |destination|
        violating_settings?(cfn_model, destination)
      end
      !violating_destination.empty?
    else
      false
    end
  end

  def violating_settings?(cfn_model, destination)
    if !destination['Settings'].nil?
      violating_setting = destination['Settings'].select do |parameter|
        channel_has_insecure_parameter?(cfn_model, parameter)
      end
      !violating_setting.empty?
    else
      false
    end
  end

  def channel_has_insecure_parameter?(cfn_model, parameter)
    if parameter['PasswordParam'].nil?
      false
    else
      insecure_parameter?(cfn_model, parameter['PasswordParam']) ||
        insecure_string_or_dynamic_reference?(cfn_model, parameter['PasswordParam'])
    end
  end
end
