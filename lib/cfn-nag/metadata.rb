# frozen_string_literal: true

require 'cfn-model'

##
# Mix-in with metadata handling routines for the CustomRuleLoader
module Metadata
  # XXX given mangled_metadatas is never used or returned,
  # STDERR emit can be moved to unless block
  def validate_cfn_nag_metadata(cfn_model)
    mangled_metadatas = collect_mangled_metadata(cfn_model)
    mangled_metadatas.each do |mangled_metadata|
      logical_resource_id = mangled_metadata.first
      mangled_rules = mangled_metadata[1]

      $stderr.puts "#{logical_resource_id} has missing cfn_nag suppression rule id: #{mangled_rules}"
    end
  end

  def cfn_model_with_suppressed_resources_removed(cfn_model:,
                                                  rule_id:,
                                                  allow_suppression:,
                                                  print_suppression:)
    return cfn_model unless allow_suppression

    cfn_model = cfn_model.copy

    cfn_model.resources.delete_if do |logical_resource_id, resource|
      rules_to_suppress = rules_to_suppress resource
      if rules_to_suppress.nil?
        false
      else
        suppress_resource?(rules_to_suppress, rule_id, logical_resource_id, print_suppression)
      end
    end
    cfn_model
  end

  private

  def suppress_resource?(rules_to_suppress, rule_id, logical_resource_id, print_suppression)
    found_suppression_rule = rules_to_suppress.find do |rule_to_suppress|
      next if rule_to_suppress['id'].nil?

      rule_to_suppress['id'] == rule_id
    end
    if found_suppression_rule && print_suppression
      message = "Suppressing #{rule_id} on #{logical_resource_id} for reason: #{found_suppression_rule['reason']}"
      $stderr.puts message
    end
    !found_suppression_rule.nil?
  end

  def rules_to_suppress(resource)
    if resource.metadata &&
       resource.metadata['cfn_nag'] &&
       resource.metadata['cfn_nag']['rules_to_suppress']

      resource.metadata['cfn_nag']['rules_to_suppress']
    end
  end

  def collect_mangled_metadata(cfn_model)
    mangled_metadatas = []
    cfn_model.resources.each do |logical_resource_id, resource|
      resource_rules_to_suppress = rules_to_suppress resource
      next if resource_rules_to_suppress.nil?

      mangled_rules = resource_rules_to_suppress.select do |rule_to_suppress|
        rule_to_suppress['id'].nil?
      end
      unless mangled_rules.empty?
        mangled_metadatas << [logical_resource_id, mangled_rules]
      end
    end
    mangled_metadatas
  end
end
