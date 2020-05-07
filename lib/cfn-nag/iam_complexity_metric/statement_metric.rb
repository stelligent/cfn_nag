# frozen_string_literal: true

require_relative 'weights'
require_relative 'condition_metric'
require 'set'

class StatementMetric
  include Weights

  # rubocop:disable Metrics/AbcSize
  def metric(statement)
    aggregate = weights[:Base_Statement]

    aggregate += effect_metrics(statement)
    aggregate += inversion_metrics(statement)
    aggregate += extra_service_count(statement) * weights[:Extra_Service]
    aggregate += misaligned_resource_action_count(statement) * weights[:Resource_Action_NotAligned]
    aggregate += mixed_wildcard(statement) * weights[:Mixed_Wildcard]

    aggregate += ConditionMetric.new.metric(statement) unless statement.condition.nil?

    aggregate
  end
  # rubocop:enable Metrics/AbcSize

  private

  def effect_metrics(statement)
    aggregate = 0
    aggregate += weights[:Deny] if statement.effect == 'Deny'
    aggregate += weights[:Allow] if statement.effect == 'Allow'
    aggregate
  end

  def inversion_metrics(statement)
    aggregate = 0
    aggregate += weights[:NotAction] unless statement.not_actions.empty?
    aggregate += weights[:NotResource] unless statement.not_resources.empty?
    aggregate
  end

  def mixed_wildcard(statement)
    count = 0
    count += 1 if action_service_names(statement).include?('*') && action_service_names(statement).size > 1
    count += 1 if resource_service_names(statement).include?('*') && resource_service_names(statement).size > 1
    count
  end

  def misaligned_resource_action_count(statement)
    return 0 if resource(statement) == ['*'] || action(statement) == ['*']

    resource_service_names = resource(statement).map { |resource_arn| resource_service_name(resource_arn) }
    action_service_names = action(statement).map { |action| action_service_name(action) }

    (set_without_wildcard(resource_service_names) - set_without_wildcard(action_service_names)).size
  end

  # rubocop:disable Naming/AccessorMethodName
  def set_without_wildcard(array)
    Set.new(array).delete('*')
  end
  # rubocop:enable Naming/AccessorMethodName

  def extra_service_count(statement)
    service_names = Set.new(action_service_names(statement) + resource_service_names(statement)).delete('*')
    [service_names.size - 1, 0].max
  end

  def action_service_names(statement)
    action(statement).map { |action| action_service_name(action) }
  end

  def resource_service_names(statement)
    resource(statement).map { |resource_arn| resource_service_name(resource_arn) }
  end

  def action_service_name(action)
    return '*' if action == '*'

    return action unless action.is_a?(String)

    action.split(':')[0]
  end

  def resource_service_name(resource_arn)
    return '*' if resource_arn == '*'

    return resource_arn unless resource_arn.is_a?(String)

    resource_arn.split(':')[2]
  end

  def action(statement)
    return statement.actions unless statement.actions.empty?

    statement.not_actions
  end

  def resource(statement)
    return statement.resources unless statement.resources.empty?

    statement.not_resources
  end
end
