violation '.Resources[] | select(.Type == "AWS::IAM::User")|'\
          'select(.Properties.Policies|length > 0) ' do |iam_user|
  message 'warning', 'IAM user should not have any directly attached policies.  Should be on group', iam_user
end

violation '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
        'select(.Properties.Users|length > 0) ' do |iam_roles|
  message 'warning', 'IAM policy should not apply directly to users.  Should be on group', iam_roles
end

violation '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
        'select(.Properties.Users|length > 0) ' do |iam_roles|
  message 'warning', 'IAM policy should not apply directly to users.  Should be on group', iam_roles
end


# AWS::IAM::UserToGroupAddition
# violation '.Resources[] | select(.Type == "AWS::IAM::User")|'\
#           'select(.Properties.Groups|length == 0) ' do |iam_user|
#   message 'warning', 'IAM user should be in at least one group.', iam_user
# end
