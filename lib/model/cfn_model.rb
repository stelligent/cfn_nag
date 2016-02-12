require 'json'
require_relative 'security_group_parser'

# consider a canonical form for template too...
# always transform optional things into more general forms....

class CfnModel
  def initialize
    @parser_registry = {
      'AWS::EC2::SecurityGroup' => SecurityGroupParser,
      'AWS::EC2::SecurityGroupIngress' => SecurityGroupXgressParser,
      'AWS::EC2::SecurityGroupEgress' => SecurityGroupXgressParser
    }
    @dangling_ingress_or_egress_rules = []
    @dangler = Object.new
  end

  def parse(cfn_json_string)
    @json_hash = JSON.load cfn_json_string
    self
  end

  def security_groups
    security_groups_hash = resources_by_type('AWS::EC2::SecurityGroup')
    wire_ingress_rules_to_security_groups(security_groups_hash)
    wire_egress_rules_to_security_groups(security_groups_hash)
    security_groups_hash.values
  end

  def dangling_ingress_or_egress_rules
    @dangling_ingress_or_egress_rules
  end

  private

  def resolve_group_id(group_id)
    if not group_id['Ref'].nil?
      group_id['Ref']
    elsif not group_id['Fn::GetAtt'].nil?
      fail unless group_id['Fn::GetAtt'][1] == 'GroupId'
      group_id['Fn::GetAtt'][0]
    else
      @dangling_ingress_or_egress_rules << group_id
      @dangler
    end
  end

  def wire_ingress_rules_to_security_groups(security_groups_hash)
    resources_by_type('AWS::EC2::SecurityGroupIngress').each do |resource_name, ingress_rule|
      if not ingress_rule['GroupId'].nil?
        group_id = resolve_group_id(ingress_rule['GroupId'])

        unless group_id == @dangler
          security_groups_hash[group_id].add_ingress_rule ingress_rule
        end
      else
        fail "GroupId must be set: #{ingress_rule}"
      end
    end
    security_groups_hash
  end

  def wire_egress_rules_to_security_groups(security_groups_hash)
    resources_by_type('AWS::EC2::SecurityGroupEgress').each do |resource_name, egress_rule|
      if not egress_rule['GroupId'].nil?
        group_id = resolve_group_id(egress_rule['GroupId'])

        unless group_id == @dangler
          security_groups_hash[group_id].add_egress_rule egress_rule
        end
      else
        fail "GroupId must be set: #{egress_rule}"
      end
    end
    security_groups_hash
  end

  def resources
    @json_hash['Resources']
  end

  def resources_by_type(resource_type)
    resources_map = {}
    resources.each do |resource_name, resource|
      if resource['Type'] == resource_type
        resource_parser = @parser_registry[resource_type].new
        resources_map[resource_name] = resource_parser.parse(resource_name, resource)
      end
    end
    resources_map
  end
end

class SecurityGroup
  attr_accessor :group_description, :vpc_id, :logical_resource_id
  attr_reader :ingress_rules, :egress_rules

  def initialize
    @ingress_rules = []
    @egress_rules = []
  end

  def add_ingress_rule(ingress_rule)
    @ingress_rules << ingress_rule
  end

  def add_egress_rule(egress_rule)
    @egress_rules << egress_rule
  end

  def to_s
    <<-END
    {
      logical_resource_id: #{@logical_resource_id}
      group_description: #{@group_description}
      vpc_id: #{@vpc_id}
      ingress_rules: #{@ingress_rules}
      egress_rules: #{@egress_rules}
    }
    END
  end
end
