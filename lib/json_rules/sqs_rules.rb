sqs_wildcard_action_filter = <<END
def sqs_wildcard_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (if .Statement.Action|type=="string" then (.Statement.Action == "sqs:*") else (.Statement.Action|indices("sqs:*")|length > 0) end))
  else select(.Statement[]|.Effect == "Allow" and (if .Action|type=="string" then (.Action == "sqs:*") else (.Action|indices("sqs:*")|length > 0) end))
  end;
END

sqs_wildcard_principal_filter = <<END
def sqs_wildcard_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (.Statement.Principal?|type=="string") and (.Statement.Principal == "*") )
  else select(.Statement[]|.Effect == "Allow" and ((.Principal?|type=="string") and (.Principal == "*")) )
  end;
END

violation jq: sqs_wildcard_action_filter +
              "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|sqs_wildcard_action)]|map(.LogicalResourceId) ",
          message: 'SQS Queue policy should not allow * action'

violation jq: sqs_wildcard_principal_filter +
              "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|sqs_wildcard_principal)]|map(.LogicalResourceId) ",
          message: 'SQS Queue policy should not allow * principal'