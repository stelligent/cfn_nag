require_relative 'cfn_model'


class IamUserParser

  def parse(resource_name, resource_json)
    properties = resource_json['Properties']
    iam_user = IamUser.new

    iam_user.logical_resource_id = resource_name

    unless properties.nil?
      unless properties['Groups'].nil?
        properties['Groups'].each do |group|
          iam_user.add_group group
        end
      end
    end

    iam_user
  end
end

class IamUserToGroupAdditionParser

  def parse(resource_name, resource_json)
    user_to_group_addition = {}
    user_to_group_addition['logical_resource_id'] = resource_name
    resource_json['Properties'].each_pair do |key, value|
      user_to_group_addition[key] = value
    end
    user_to_group_addition
  end
end
