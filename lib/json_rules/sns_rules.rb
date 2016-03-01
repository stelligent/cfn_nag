sns_wildcard_principal_filter = <<END
def sns_wildcard_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (.Statement.Principal?|type=="string") and (.Statement.Principal == "*"))
  else select(.Statement[]|(.Effect == "Allow" and (.Principal?|type=="string") and (.Principal == "*")))
  end;
END

sns_wildcard_aws_principal_filter = <<END
def sns_wildcard_aws_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (.Statement.Principal?|type=="object") and (.Statement.Principal.AWS == "*"))
  else select(.Statement[]|(.Effect == "Allow" and (.Principal?|type=="object") and (.Principal.AWS == "*")))
  end;
END

# i guess we could have principal "AWS": ["1111111111", "*", "222222222222"]... or ["*","arn:..."]

#sns action wildcard doesnt seem to be accepted by sns so dont sweat it

violation jq: sns_wildcard_principal_filter +
              "[#{resources_by_type('AWS::SNS::TopicPolicy')}|select(.Properties.PolicyDocument|sns_wildcard_principal)]|map(.LogicalResourceId) ",
          message: 'SNS topic policy should not allow * principal'

violation jq: sns_wildcard_aws_principal_filter +
              "[#{resources_by_type('AWS::SNS::TopicPolicy')}|select(.Properties.PolicyDocument|sns_wildcard_aws_principal)]|map(.LogicalResourceId) ",
          message: 'SNS topic policy should not allow * AWS principal'