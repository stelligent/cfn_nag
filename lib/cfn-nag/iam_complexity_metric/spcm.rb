# frozen_string_literal: true

require 'cfn-nag/template_discovery'
require 'cfn-model'
require_relative 'policy_document_metric'

class SPCM
  DEFAULT_TEMPLATE_PATTERN = '..*\.json$|..*\.yaml$|..*\.yml$|..*\.template$'

  def aggregate_metrics(input_path:,
                        parameter_values_path: nil,
                        condition_values_path: nil,
                        template_pattern: DEFAULT_TEMPLATE_PATTERN)
    parameter_values_string = parameter_values_path.nil? ? nil : IO.read(parameter_values_path)
    condition_values_string = condition_values_path.nil? ? nil : IO.read(condition_values_path)

    templates = TemplateDiscovery.new.discover_templates(input_json_path: input_path,
                                                         template_pattern: template_pattern)
    aggregate_results = []
    templates.each do |template|
      aggregate_results << {
        filename: template,
        file_results: metric(
          cloudformation_string: IO.read(template),
          parameter_values_string: parameter_values_string,
          condition_values_string: condition_values_string
        )
      }
    end
    aggregate_results
  end

  def metric(cloudformation_string:, parameter_values_string: nil, condition_values_string: nil)
    cfn_model = CfnParser.new.parse cloudformation_string,
                                    parameter_values_string,
                                    false,
                                    condition_values_string

    metric_impl(cfn_model)
  end

  def metric_impl(cfn_model)
    policy_documents = {
      'AWS::IAM::Policy' => {},
      'AWS::IAM::Role' => {}
    }

    cfn_model.resources_by_type('AWS::IAM::Policy').each do |policy|
      update_policy_metric(policy_documents, policy)
    end

    cfn_model.resources_by_type('AWS::IAM::Role').each do |role|
      role.policy_objects.each do |policy|
        update_role_policy_metric(policy_documents, role, policy)
      end
    end

    policy_documents
  end

  private

  def update_policy_metric(policy_documents, policy)
    metric = PolicyDocumentMetric.new.metric(policy.policy_document)
    policy_documents['AWS::IAM::Policy'][policy.logical_resource_id] = metric
  end

  def update_role_policy_metric(policy_documents, role, policy)
    metric = PolicyDocumentMetric.new.metric(policy.policy_document)

    if policy_documents['AWS::IAM::Role'][role.logical_resource_id]
      policy_documents['AWS::IAM::Role'][role.logical_resource_id][policy.policy_name.to_s] = metric
    else
      policy_documents['AWS::IAM::Role'][role.logical_resource_id] = {
        policy.policy_name.to_s => metric
      }
    end
  end
end
