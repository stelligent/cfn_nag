require 'json'
require_relative 'security_group_parser'
require_relative 'iam_user_parser'
require_relative 's3_bucket_policy_parser'

# consider a canonical form for template too...
# always transform optional things into more general forms....
# although referencing violations becomes tricky then (a la c preprocessor)

class CfnModel
  def initialize
    @parser_registry = {
      'AWS::EC2::SecurityGroup' => SecurityGroupParser,
      'AWS::EC2::SecurityGroupIngress' => SecurityGroupXgressParser,
      'AWS::EC2::SecurityGroupEgress' => SecurityGroupXgressParser,
      'AWS::IAM::User' => IamUserParser,
      'AWS::IAM::UserToGroupAddition' => IamUserToGroupAdditionParser,
      'AWS::S3::BucketPolicy' => S3BucketPolicyParser
    }
    @dangling_ingress_or_egress_rules = []
    @dangler = Object.new
  end

  def parse(cfn_json_string)
    @json_hash = JSON.load cfn_json_string
    self
  end

  def security_groups
    fail 'must call parse first' unless @json_hash
    security_groups_hash = resources_by_type('AWS::EC2::SecurityGroup')
    wire_ingress_rules_to_security_groups(security_groups_hash)
    wire_egress_rules_to_security_groups(security_groups_hash)
    security_groups_hash.values
  end

  def dangling_ingress_or_egress_rules
    fail 'must call parse first' unless @json_hash
    @dangling_ingress_or_egress_rules
  end

  def iam_users
    fail 'must call parse first' unless @json_hash
    iam_users_hash = resources_by_type('AWS::IAM::User')
    wire_user_to_group_additions_to_users(iam_users_hash)
    iam_users_hash.values
  end

  def bucket_policies
    bucket_policy_hash = resources_by_type('AWS::S3::BucketPolicy')
    bucket_policy_hash.values
  end

  private

  def resolve_user_logical_resource_id(user)
    if not user['Ref'].nil?
      user['Ref']
    elsif not user['Fn::GetAtt'].nil?
      fail 'Arn not legal for user to group addition'
    else
      @dangler
    end
  end

  def resolve_group_id(group_id)
    if not group_id['Ref'].nil?
      group_id['Ref']
    elsif not group_id['Fn::GetAtt'].nil?
      fail 'GroupId only legal att on security group resource' unless group_id['Fn::GetAtt'][1] == 'GroupId'
      group_id['Fn::GetAtt'][0]
    else
      @dangling_ingress_or_egress_rules << group_id
      @dangler
    end
  end

  def wire_user_to_group_additions_to_users(iam_users_hash)
    resources_by_type('AWS::IAM::UserToGroupAddition').each do |resource_name, user_to_group_addition|
      user_to_group_addition['Users'].each do |user|
        unless resolve_user_logical_resource_id(user) == @dangler
          iam_users_hash[resolve_user_logical_resource_id(user)].add_group user_to_group_addition['GroupName']
        end
      end
    end
    iam_users_hash
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

class IamUser
  attr_accessor :logical_resource_id
  attr_reader :groups

  def initialize
    @groups = []
  end

  def add_group(group)
    @groups << group
  end

  def to_s
    <<-END
    {
      logical_resource_id: #{@logical_resource_id}
      groups: #{@groups}
    }
    END
  end
end

