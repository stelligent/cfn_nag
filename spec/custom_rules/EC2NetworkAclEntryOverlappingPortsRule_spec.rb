require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryOverlappingPortsRule'
require 'cfn-model'

describe EC2NetworkAclEntryOverlappingPortsRule do
  context 'Multiple EC2 Network ACLs reuse the same ports for 2 egress entries OR 2 ingress entries' do
    it 'returns the offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_reused_ports.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry myNetworkAclEntry2 myNetworkAclEntry3 myNetworkAclEntry4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs reuse the same ports for 1 egress entry and 1 ingress entry' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_egress_ingress_reused_ports.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs entries do not reuse ports' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_no_reused_ports.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs entries ports overlap' do
    it 'returns the offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_port_overlaps.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry myNetworkAclEntry2 myNetworkAclEntry4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs entries ports overlap for non TCP/UDP protocols' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_port_overlap_non_tcp_udp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs entries ports do not overlap' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_no_port_overlaps.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end


  context 'EC2 Network ACLs entries ports overlap but across IP4/IP6' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/ec2_networkaclentry/ip6_and_ip4_nacl.yml'
                                      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EC2 Network ACLs entries contain references' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/ec2_networkaclentry/ref_ports.yml'
                                      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end

    it 'returns warnings when provided conflicting parameter values' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/ec2_networkaclentry/ref_ports.yml'
                                      ),
                                      JSON.generate({Parameters: { NaclPort: 80 }})

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[InboundHTTPPublicNetworkAclEntry InboundHTTPPublicNetworkAclEntry2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EC2 Network ACLs entries without direct nacl resource' do
    it 'returns expected duplicates' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/ec2_networkaclentry/overlapping_ports_no_nacl.yml'
                                      )

      actual_logical_resource_ids = EC2NetworkAclEntryOverlappingPortsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[BadNaclEntry1 BadNaclEntry2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
