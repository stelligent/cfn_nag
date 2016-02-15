wildcard_action_filter =
    'def wildcard_action: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement|if .Action|type=="string" then select(.Action == "*") else select(.Action|contains(["*"])) end) '\
      'else select(.Statement[]|if .Action|type=="string" then select(.Effect == "Allow" and .Action == "*") else select(.Effect == "Allow" and (.Action|contains(["*"]))) end) '\
      'end; '

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
          'select(.Properties.AssumeRolePolicyDocument|wildcard_action) ' do |iam_roles|
  message 'warning', 'IAM role should not allow * action on its trust policy', iam_roles
end

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
          'select(.Properties.Policies[].PolicyDocument|wildcard_action) ' do |iam_roles|
  message 'warning', 'IAM role should not allow * action on its permissions policy', iam_roles
end

violation wildcard_action_filter +
              '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
          'select(.Properties.PolicyDocument|wildcard_action) ' do |iam_roles|
  message 'warning', 'IAM policy should not allow * action', iam_roles
end

violation wildcard_action_filter +
              '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
          'select(.Properties.PolicyDocument|wildcard_action) ' do |iam_roles|
  message 'warning', 'IAM policy should not allow * action', iam_roles
end

wildcard_resource_filter =
    'def wildcard_resource: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement|if .Resource|type=="string" then select(.Resource == "*") else select(.Resource|contains(["*"])) end) '\
      'else select(.Statement[]|if .Resource|type=="string" then select(.Effect == "Allow" and .Resource == "*") else select(.Effect == "Allow" and (.Resource|contains(["*"]))) end) '\
      'end; '

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
        'select(.Properties.Policies[].PolicyDocument|wildcard_resource) ' do |iam_roles|
  message 'warning', 'IAM role should not allow * resource on its permissions policy', iam_roles
end

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
        'select(.Properties.PolicyDocument|wildcard_resource) ' do |iam_roles|
  message 'warning', 'IAM policy should not allow * resource', iam_roles
end

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
        'select(.Properties.PolicyDocument|wildcard_resource) ' do |iam_roles|
  message 'warning', 'IAM policy should not allow * resource', iam_roles
end


# watch out for Deny + NotResource ??????