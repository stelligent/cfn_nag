require_relative '../rule'

class UserMissingGroupRule
  include Rule

  def audit(cfn_model)
    violation_count = 0

    logical_resource_ids = []
    violating_iam_users = []
    cfn_model.iam_users.each do |iam_user|
      if iam_user.groups.size == 0
        logical_resource_ids << iam_user.logical_resource_id
        violating_iam_users << iam_user
        violation_count += 1
      end
    end

    if violation_count > 0
      message message_type: 'violation',
              message: 'User is not assigned to a group',
              logical_resource_ids: logical_resource_ids
    end
    violation_count
  end
end