require_relative '../violation'

class UserMissingGroupRule

  def rule_text
    'User is not assigned to a group'
  end

  def audit(cfn_model)
    logical_resource_ids = []
    cfn_model.iam_users.each do |iam_user|
      if iam_user.groups.size == 0
        logical_resource_ids << iam_user.logical_resource_id
      end
    end

    if logical_resource_ids.size > 0
      Violation.new(type: Violation::FAILING_VIOLATION,
                    message: rule_text,
                    logical_resource_ids: logical_resource_ids)
    else
      nil
    end
  end
end