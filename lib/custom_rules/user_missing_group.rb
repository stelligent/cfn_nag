require_relative '../rule'

class UserMissingGroupRule
  include Rule

  def audit(cfn_model)
    violation_count = 0

    cfn_model.iam_users.each do |iam_user|
      if iam_user.groups.size == 0
        message 'violation', 'User is not assigned to a group', iam_user
        violation_count += 1
      end
    end
    violation_count
  end
end