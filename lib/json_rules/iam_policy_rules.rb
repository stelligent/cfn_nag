wildcard_action_filter =
    'def wildcard_action: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement|if .Action|type=="string" then select(.Action == "*") else select(.Action|index("*")) end) '\
      'else select(.Statement[]|if .Action|type=="string" then select(.Effect == "Allow" and .Action == "*") else select(.Effect == "Allow" and (.Action|index("*"))) end) '\
      'end; '

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
          'select(.Properties.AssumeRolePolicyDocument|wildcard_action) ' do |iam_roles|
  message 'violation', 'IAM role should not allow * action on its trust policy', iam_roles
end

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
          'select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|wildcard_action) ' do |iam_roles|
  message 'violation', 'IAM role should not allow * action on its permissions policy', iam_roles
end

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
          'select(.Properties.PolicyDocument|wildcard_action) ' do |policies|
  message 'violation', 'IAM policy should not allow * action', policies
end

violation wildcard_action_filter +
          '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
          'select(.Properties.PolicyDocument|wildcard_action) ' do |managed_policies|
  message 'violation', 'IAM managed policy should not allow * action', managed_policies
end

wildcard_resource_filter =
    'def wildcard_resource: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement|if .Resource|type=="string" then select(.Resource == "*") else select(.Resource|index("*")) end) '\
      'else select(.Statement[]|if .Resource|type=="string" then select(.Effect == "Allow" and .Resource == "*") else (if .Resource|type=="array" then select(.Effect == "Allow" and (.Resource|index("*"))) else false end) end) '\
      'end; '

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
        'select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|wildcard_resource) ' do |iam_roles|
  message 'warning', 'IAM role should not allow * resource on its permissions policy', iam_roles
end

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
        'select(.Properties.PolicyDocument|wildcard_resource) ' do |policies|
  message 'warning', 'IAM policy should not allow * resource', policies
end

warning wildcard_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
        'select(.Properties.PolicyDocument|wildcard_resource) ' do |managed_policies|
  message 'warning', 'IAM managed policy should not allow * resource', managed_policies
end

allow_not_action_filter =
    'def allow_not_action: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement.NotAction != null) '\
      'else select(.Statement[]|select(.NotAction != null and .Effect == "Allow")) '\
      'end; '

warning allow_not_action_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
        'select(.Properties.AssumeRolePolicyDocument|allow_not_action) ' do |iam_roles|
  message 'warning', 'IAM role should not allow Allow+NotAction', iam_roles
end

warning allow_not_action_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
        'select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|allow_not_action) ' do |iam_roles|
  message 'warning', 'IAM role should not allow Allow+NotAction', iam_roles
end

warning allow_not_action_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
        'select(.Properties.PolicyDocument|allow_not_action) ' do |policies|
  message 'warning', 'IAM policy should not allow Allow+NotAction', policies
end

warning allow_not_action_filter +
        '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
        'select(.Properties.PolicyDocument|allow_not_action) ' do |managed_policies|
  message 'warning', 'IAM managed policy should not allow Allow+NotAction', managed_policies
end

allow_not_resource_filter =
    'def allow_not_resource: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement.NotResource != null) '\
      'else select(.Statement[]|select(.NotResource != null and .Effect == "Allow")) '\
      'end; '

warning allow_not_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
        'select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|allow_not_resource) ' do |iam_roles|
  message 'warning', 'IAM role should not allow Allow+NotResource', iam_roles
end

warning allow_not_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::Policy")|'\
        'select(.Properties.PolicyDocument|allow_not_resource) ' do |policies|
  message 'warning', 'IAM policy should not allow Allow+NotResource', policies
end

warning allow_not_resource_filter +
        '.Resources[] | select(.Type == "AWS::IAM::ManagedPolicy")|'\
        'select(.Properties.PolicyDocument|allow_not_resource) ' do |managed_policies|
  message 'warning', 'IAM managed policy should not allow Allow+NotResource', managed_policies
end

allow_not_principal_filter =
    'def allow_not_principal: '\
      'if .Statement|type == "object" '\
      'then select(.Statement.Effect == "Allow" and .Statement.NotPrincipal != null) '\
      'else select(.Statement[]|select(.NotPrincipal != null and .Effect == "Allow")) '\
      'end; '

violation allow_not_principal_filter +
          '.Resources[] | select(.Type == "AWS::IAM::Role")|'\
          'select(.Properties.AssumeRolePolicyDocument|allow_not_principal) ' do |iam_roles|
  message 'violation', 'IAM role should not allow Allow+NotPrincipal in its trust policy', iam_roles
end