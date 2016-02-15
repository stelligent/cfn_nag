require_relative 'cfn_model'

class SecurityGroupParser

  # precondition: properties are actually there... other validator takes care
  def parse(resource_name, resource_json)
    properties = resource_json['Properties']
    security_group = SecurityGroup.new

    parse_ingress_rules(security_group, properties)

    parse_egress_rules(security_group, properties)

    security_group.vpc_id = properties['VpcId']
    security_group.group_description = properties['GroupDescription']
    security_group.logical_resource_id = resource_name

    security_group
  end

  private

  def parse_ingress_rules(security_group, properties)
    unless properties['SecurityGroupIngress'].nil?
      if properties['SecurityGroupIngress'].is_a? Array
        properties['SecurityGroupIngress'].each do |ingress_json|
          security_group.add_ingress_rule ingress_json
        end
      elsif properties['SecurityGroupIngress'].is_a? Hash
        security_group.add_ingress_rule properties['SecurityGroupIngress']
      end
    end
  end

  def parse_egress_rules(security_group, properties)
    unless properties['SecurityGroupEgress'].nil?
      if properties['SecurityGroupEgress'].is_a? Array
        properties['SecurityGroupEgress'].each do |egress_json|
          security_group.add_egress_rule egress_json
        end
      elsif properties['SecurityGroupEgress'].is_a? Hash
        security_group.add_egress_rule properties['SecurityGroupEgress']
      end
    end
  end

end

class SecurityGroupXgressParser

  def parse(resource_name, resource_json)
    unless resource_json['Properties']['GroupName'].nil?
      fail "GroupName is only allowed in EC2-Classic, and we dont play that!: #{resource_json}"
    end

    xgress = {}
    xgress['logical_resource_id'] = resource_name
    resource_json['Properties'].each_pair do |key, value|
      xgress[key] = value
    end
    xgress
  end
end