class SecurityGroupParser

  def parse(resource_json)
    properties = resource_json['Properties']
    security_group = SecurityGroup.new

    #pre-validation of structure somehow to make life easier here?
    #unless properties.nil?

    unless properties['SecurityGroupIngress'].nil?
      if properties['SecurityGroupIngress'].is_a? Array
        properties['SecurityGroupIngress'].each do |ingress_json|
          security_group.add_ingress_rule ingress_json
        end
      elsif properties['SecurityGroupIngress'].is_a? Hash
        security_group.add_ingress_rule properties['SecurityGroupIngress']
      end
    end

    #generalize?
    security_group.vpc_id = properties['VpcId']
    security_group.group_description = properties['GroupDescription']

    security_group
  end
end

class SecurityGroupIngressParser

  def parse(resource_json)
    security_group_ingress_rule = SecurityGroupIngressRule.new

    properties = resource_json['Properties']

    unless properties['GroupName'].nil?
      fail 'GroupName is only allowed in EC2-Classic, and we dont play that!'
    end

    security_group_ingress_rule.group_id = properties['GroupId']
    security_group_ingress_rule.to_port = properties['ToPort']
    security_group_ingress_rule.from_port = properties['FromPort']
    security_group_ingress_rule.ip_protocol = properties['IpProtocol']
    security_group_ingress_rule.cidr_ip = properties['CidrIp']
    security_group_ingress_rule
  end
end

class SecurityGroupIngressRule
  attr_accessor :to_port, :ip_protocol, :from_port, :cidr_ip, :group_id
end

class SecurityGroup
  attr_accessor :group_description, :vpc_id
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
end

# def method_missing(name)
#   return self[name] if key? name
#   self.each { |k,v| return v if k.to_s.to_sym == name }
#   super.method_missing name
# end