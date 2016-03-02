wildcard_action_filter = <<END
def wildcard_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (if .Statement.Action|type=="string" then (.Statement.Action == "*") else (.Statement.Action|indices("*")|length > 0) end))
  else select(.Statement[]|.Effect == "Allow" and (if .Action|type=="string" then (.Action == "*") else (.Action|indices("*")|length > 0) end))
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
  then select(.Statement.Effect == "Allow" and (if .Statement.Resource|type=="string" then (.Statement.Resource == "*") else (.Statement.Resource|indices("*")|length > 0) end))
  else select(.Statement[]|.Effect == "Allow" and (if .Resource|type=="string" then (.Resource == "*") else (.Statement.Resource|indices("*")|length > 0) end))
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
  else select(.Statement[]|(.Effect == "Allow" and .NotAction != null))
  end;
END

warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.AssumeRolePolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow Allow+NotAction on trust permissinos'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.Policies !=null)|select(.Properties.Policies[].PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM role should not allow Allow+NotAction'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::Policy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM policy should not allow Allow+NotAction'


warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::IAM::ManagedPolicy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'IAM managed policy should not allow Allow+NotAction'

warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'SQS Queue policy should not allow Allow+NotAction'

warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::SNS::TopicPolicy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'SNS Topic policy should not allow Allow+NotAction'

warning jq: allow_not_action_filter +
            "[#{resources_by_type('AWS::S3::BucketPolicy')}|select(.Properties.PolicyDocument|allow_not_action)]|map(.LogicalResourceId)",
        message: 'S3 Bucket policy should not allow Allow+NotAction'

allow_not_resource_filter = <<END
def allow_not_resource:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and .Statement.NotResource != null)
  else select(.Statement[]|(.Effect == "Allow" and .NotResource != null))
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
  else select(.Statement[]|(.Effect == "Allow" and .NotPrincipal != null))
  end;
END

violation jq: allow_not_principal_filter +
              "[#{resources_by_type('AWS::IAM::Role')}|select(.Properties.AssumeRolePolicyDocument|allow_not_principal)]|map(.LogicalResourceId)",
          message: 'IAM role should not allow Allow+NotPrincipal in its trust policy'

violation jq: allow_not_principal_filter +
              "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|allow_not_principal)]|map(.LogicalResourceId)",
          message: 'SQS Queue policy should not allow Allow+NotPrincipal'

violation jq: allow_not_principal_filter +
              "[#{resources_by_type('AWS::SNS::TopicPolicy')}|select(.Properties.PolicyDocument|allow_not_principal)]|map(.LogicalResourceId)",
          message: 'SNS Topic policy should not allow Allow+NotPrincipal'

violation jq: allow_not_principal_filter +
              "[#{resources_by_type('AWS::S3::BucketPolicy')}|select(.Properties.PolicyDocument|allow_not_principal)]|map(.LogicalResourceId)",
          message: 'S3 Bucket policy should not allow Allow+NotPrincipal'