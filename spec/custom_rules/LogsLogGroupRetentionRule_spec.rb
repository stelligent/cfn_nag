require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/LogsLogGroupRetentionRule'

describe LogsLogGroupRetentionRule do
  context 'CloudWatchLogs LogGroup without retention' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/cloudwatchlogs_loggroup/cloudwatchlogs_loggroup_without_retention.yaml'
      )

      actual_logical_resource_ids = LogsLogGroupRetentionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CWLogGroup]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'CloudWatchLogs LogGroup with retention' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/cloudwatchlogs_loggroup/cloudwatchlogs_loggroup_with_retention.yaml'
      )

      actual_logical_resource_ids = LogsLogGroupRetentionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end