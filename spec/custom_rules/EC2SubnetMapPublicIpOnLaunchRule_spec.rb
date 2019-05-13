require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EC2SubnetMapPublicIpOnLaunchRule'

describe EC2SubnetMapPublicIpOnLaunchRule do
  context 'when EC2::Subnet does not have MapPublicIpOnLaunch specified' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_no_map_public_ip_on_launch_specified.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==true boolean' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[EC2Subnet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==True Boolean' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean_case.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[EC2Subnet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==true string' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_string.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[EC2Subnet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==True String' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_string_case.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[EC2Subnet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==false boolean' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_false_boolean.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==False Boolean' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_false_boolean_case.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==false string' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_false_string.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when EC2::Subnet has MapPublicIpOnLaunch==False String' do
    it 'returns offending logical resource id for offending Subnet' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_false_string_case.yml'
      )

      actual_logical_resource_ids =
        EC2SubnetMapPublicIpOnLaunchRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
