require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/AmazonMQBrokerEncryptionOptionsRule'

describe AmazonMQBrokerEncryptionOptionsRule do
  context 'AmazonMQBroker with no EncryptOptions' do
    it 'Returns the logical resource ID of the offending AmazonMQBroker resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/amazon_mq/amazon_mq_broker_no_encrypt_options.yaml'
      )

      actual_logical_resource_ids =
        AmazonMQBrokerEncryptionOptionsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AmazonMQBroker]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'AmazonMQBroker with EncryptOptions' do
    it 'Returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/amazon_mq/amazon_mq_broker_encrypt_options.yaml'
      )

      actual_logical_resource_ids =
        AmazonMQBrokerEncryptionOptionsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

end
