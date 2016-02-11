require 'json'
require_relative 'security_group_parser'

# consider a canonical form for template too...
# always transform optional things into more general forms....

class CfnModel
  def initialize
    @parser_registry = {
      'AWS::EC2::SecurityGroup' => SecurityGroupParser,
      'AWS::EC2::SecurityGroupIngress' => SecurityGroupIngressParser
    }
  end

  def parse(cfn_json_string)
    @json_hash = JSON.load cfn_json_string
    self
  end

  def security_groups
    security_groups_hash = resources_by_type('AWS::EC2::SecurityGroup')
    wire_ingress_rules_to_security_groups(security_groups_hash)
    #dangling ingress rules
    security_groups_hash.values
  end

  private

  def resolve_group_id(security_groups_hash, group_id)
    if not group_id['Ref'].nil?
      group_id['Ref']
    elsif not group_id['Fn::GetAtt'].nil?
      group_id['Fn::GetAtt'][0]
    else
      #dangling ingress rule
    end
  end

  def wire_ingress_rules_to_security_groups(security_groups_hash)
    resources_by_type('AWS::EC2::SecurityGroupIngress').each do |resource_name, ingress_rule|
      if not ingress_rule['GroupId'].nil?
        group_id = resolve_group_id(security_groups_hash, ingress_rule['GroupId'])
        security_groups_hash[group_id].add_ingress_rule ingress_rule
      else
        fail "GroupId must be set: #{ingress_rule}"
      end
    end
  end

  def resources
    @json_hash['Resources']
  end

  def resources_by_type(resource_type)
    resources_map = {}
    resources.each do |resource_name, resource|
      if resource['Type'] == resource_type
        resource_parser = @parser_registry[resource_type].new
        resources_map[resource_name] = resource_parser.parse(resource)
      end
    end
    resources_map
  end
end
