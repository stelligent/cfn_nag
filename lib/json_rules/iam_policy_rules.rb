wildcard_action_filter = <<END
def wildcard_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement|if .Action|type=="string" then select(.Action == "*") else select(.Action|index("*")) end)
  else select(.Statement[]|if .Action|type=="string" then select(.Effect == "Allow" and .Action == "*") else select(.Effect == "Allow" and (.Action|index("*"))) end)
  end;
END

violation jq: wildcard_action_filter +
             "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.AssumeRolePolicyDocument|wildcard_action)]|map(.LogicalResourceId) ",
          message: 'IAM role should not allow * action on its trust policy'

violation jq: wildcard_action_filter +
              "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|wildcard_action)]|map(.LogicalResourceId)",
          message: 'IAM role should not allow * action on its permissions policy'


violation jq: wildcard_action_filter +
              "[#{resources_by_type('AWS::IAM::Policy')}|select(.Properties.PolicyDocument|wildcard_action)]|map(.LogicalResourceId) ",
          message: 'IAM policy should not allow * action'


violation jq: wildcard_action_filter +
              "[#{resources_by_type('AWS::IAM::ManagedPolicy')}|select(.Properties.PolicyDocument|wildcard_action)]|map(.LogicalResourceId) ",
          message: 'IAM managed policy should not allow * action'


wildcard_resource_filter = <<END
def wildcard_resource:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement|if .Resource|type=="string" then select(.Resource == "*") else select(.Resource|index("*")) end)
  else select(.Statement[]|if .Resource|type=="string" then select(.Effect == "Allow" and .Resource == "*") else (if .Resource|type=="array" then select(.Effect == "Allow" and (.Resource|index("*"))) else false end) end)
  end;
END

warning jq: wildcard_resource_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|wildcard_resource)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow * resource on its permissions policy'


warning jq: wildcard_resource_filter +
            "[#{resources_by_type('AWS::IAM::Policy')}|select(.Properties.PolicyDocument|wildcard_resource)]|map(.LogicalResourceId)",
        message: 'IAM policy should not allow * resource'

warning jq: wildcard_resource_filter +
            "[#{resources_by_type('AWS::IAM::ManagedPolicy')}|select(.Properties.PolicyDocument|wildcard_resource)]|map(.LogicalResourceId)",
        message: 'IAM managed policy should not allow * resource'

allow_not_action_filter = <<END
def allow_not_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement.NotAction != null)
  else select(.Statement[]|select(.NotAction != null and .Effect == "Allow"))
  end;
END

warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.AssumeRolePolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow Allow+NotAction'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow Allow+NotAction'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Policy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM policy should not allow Allow+NotAction'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::ManagedPolicy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM managed policy should not allow Allow+NotAction'


allow_not_resource_filter = <<END
def allow_not_resource:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement.NotResource != null)
  else select(.Statement[]|select(.NotResource != null and .Effect == "Allow"))
  end;
END

warning jq: allow_not_resource_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|allow_not_resource)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow Allow+NotResource'


warning jq: allow_not_resource_filter +
            "[#{resources_by_type('AWS::IAM::Policy')}|select(.Properties.PolicyDocument|allow_not_resource)]|map(.LogicalResourceId)",
        message: 'IAM policy should not allow Allow+NotResource'


warning jq: allow_not_resource_filter +
           "[#{resources_by_type('AWS::IAM::ManagedPolicy')}|select(.Properties.PolicyDocument|allow_not_resource)]|map(.LogicalResourceId)",
        message: 'IAM managed policy should not allow Allow+NotResource'


allow_not_principal_filter = <<END
def allow_not_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement.NotPrincipal != null)
  else select(.Statement[]|select(.NotPrincipal != null and .Effect == "Allow"))
  end;
END

violation jq: allow_not_principal_filter +
              "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.AssumeRolePolicyDocument|allow_not_principal)]|map(.LogicalResourceId)",
          message: 'IAM role should not allow Allow+NotPrincipal in its trust policy'
