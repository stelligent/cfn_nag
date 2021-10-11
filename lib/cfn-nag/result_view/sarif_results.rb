# frozen_string_literal: true

require 'json'

class SarifResults
  def render(results, rule_registry)
    sarif_results = []
    results.each do |file|
      # For each file in the results, review the violations
      file[:file_results][:violations].each do |violation|
        # For each violation, generate a sarif result for each logical resource id in the violation
        violation.logical_resource_ids.each_with_index do |_logical_resource_id, index|
          sarif_results << sarif_result(file_name: file[:filename], violation: violation, index: index)
        end
      end
    end

    sarif_report = {
      version: '2.1.0',
      '$schema': 'https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json',
      runs: [
        tool: {
          driver: driver(rule_registry.rules)
        },
        results: sarif_results
      ]
    }

    puts JSON.pretty_generate(sarif_report)
  end

  # Generates a SARIF driver object, which describes the tool and the rules used
  def driver(rules)
    {
      name: 'cfn_nag',
      informationUri: 'https://github.com/stelligent/cfn_nag',
      semanticVersion: Gem.loaded_specs['cfn-nag'].version.to_s,
      rules: rules.map do |rule_definition|
        {
          id: "CFN_NAG_#{rule_definition.id}",
          name: rule_definition.name,
          fullDescription: {
            text: rule_definition.message
          }
        }
      end
    }
  end

  # Given a cfn_nag Violation object, and index, generates a SARIF result object for the finding
  def sarif_result(file_name:, violation:, index:)
    {
      ruleId: violation.id,
      level: sarif_level(violation.type),
      message: {
        text: violation.message
      },
      locations: [
        {
          physicalLocation: {
            artifactLocation: {
              # TODO: possible to determine if this is a relative or absolute path?
              # if relative, set uriBaseId
              uri: file_name
            },
            region: {
              startLine: violation.line_numbers[index]
            }
          },
          logicalLocations: [
            {
              name: violation.logical_resource_ids[index]
            }
          ]
        }
      ]
    }
  end

  def sarif_level(violation_type)
    case violation_type
    when RuleDefinition::WARNING
      'warning'
    else
      'error'
    end
  end
end
