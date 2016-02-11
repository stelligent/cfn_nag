require 'json'
require_relative 'security_group_parser'

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
    security_groups = resources_by_type('AWS::EC2::SecurityGroup')
    wire_ingress_rules_to_security_groups(security_groups)
    #dangling ingress rules
    security_groups.values
  end

  private

  def wire_ingress_rules_to_security_groups(security_groups_hash)
    resources_by_type('AWS::EC2::SecurityGroupIngress').each do |ingress_rules|
      if not properties['GroupId'].nil?
        if not properties['GroupId']['Ref'].nil?
          unless @security_groups_hash[properties['GroupId']['Ref']].nil?
            @security_groups_hash[properties['GroupId']['Ref']].add_ingress_rule security_group_ingress_rule
          end
        else
          #dangling ingress rule
        end
      else
        p 'hi!'
      end
    end
  end

  def resources
    @json['Resources']
  end

  def resources_by_type(resource_type)
    # resources.values.select do |resource|
    #   resource['Type'] == resource_type
    # end

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

