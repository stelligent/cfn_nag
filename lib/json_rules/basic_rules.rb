raw_fatal_assertion jq: '.Resources|length > 0',
                    message: 'A Cloudformation template must have at least 1 resource'


%w(
  AWS::IAM::Role
  AWS::IAM::Policy
  AWS::IAM::ManagedPolicy
  AWS::S3::BucketPolicy
  AWS::SQS::QueuePolicy
  AWS::SNS::TopicPolicy
  AWS::IAM::UserToGroupAddition
  AWS::EC2::SecurityGroup
  AWS::EC2::SecurityGroupIngress
  AWS::EC2::SecurityGroupEgress
).each do |resource_must_have_properties|
  fatal_violation jq: "[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == \"#{resource_must_have_properties}\" and .Properties == null)]|map(.LogicalResourceId)",
                  message: "#{resource_must_have_properties} must have Properties"
end

missing_reference_jq = <<END
  (
    (
      ([..|.Ref?]|map(select(. != null)) +  [..|."Fn::GetAtt"?[0]]|map(select(. != null)))
    )
    -
    (
      ["AWS::AccountId","AWS::StackName","AWS::Region","AWS::StackId","AWS::NoValue","AWS::NotificationARNs"] +
      ([.Resources|keys]|flatten) +
      (if .Parameters? then ([.Parameters|keys]|flatten) else [] end)
    )
  )|if length==0 then false else . end
END

raw_fatal_violation jq: missing_reference_jq,
                    message: 'All Ref and Fn::GetAtt must reference existing logical resource ids'


%w(
  AWS::EC2::SecurityGroupIngress
  AWS::EC2::SecurityGroupEgress
).each do |xgress|
  fatal_violation jq: "[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == \"#{xgress}\" and .Properties.GroupName != null)]|map(.LogicalResourceId)",
                  message: "#{xgress} must not have GroupName - EC2 classic is a no-go!"
end