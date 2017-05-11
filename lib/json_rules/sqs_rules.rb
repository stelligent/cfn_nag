sqs_wildcard_action_filter = <<END
def sqs_wildcard_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (if .Statement.Action|type=="string" then (.Statement.Action | contains("*") ) else (.Statement.Action|contains(["*"])) end))
  else select(.Statement[]|.Effect == "Allow" and (if .Action|type=="string" then (.Action | contains("*")) else (.Action|contains(["*"])) end))
  end;
END

sqs_wildcard_principal_filter = <<END
def sqs_wildcard_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (((.Statement.Principal?|type=="string") and (.Statement.Principal|contains("*"))) or ((.Statement.Principal?|type=="object") and (.Statement.Principal|contains({"AWS": "*"}))) ))
  else select(.Statement[]|.Effect == "Allow" and ( ((.Principal?|type=="string") and (.Principal|contains("*"))) or ((.Principal?|type=="object") and (.Principal|contains({"AWS": "*"}))) )      )
  end;
END

violation id: 'F20',
          jq: sqs_wildcard_action_filter +
              "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|sqs_wildcard_action)]|map(.LogicalResourceId) ",
          message: 'SQS Queue policy should not allow * action'

violation id: 'F21',
          jq: sqs_wildcard_principal_filter +
              "[#{resources_by_type('AWS::SQS::QueuePolicy')}|select(.Properties.PolicyDocument|sqs_wildcard_principal)]|map(.LogicalResourceId) ",
          message: 'SQS Queue policy should not allow * principal'