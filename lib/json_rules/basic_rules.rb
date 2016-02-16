fatal_assertion '.Resources|length > 0' do
  message('fatal', 'Must have at least 1 resource')
end

%w(
  AWS::IAM::Role
  AWS::IAM::Policy
  AWS::IAM::ManagedPolicy
  AWS::IAM::UserToGroupAddition
  AWS::EC2::SecurityGroup
  AWS::EC2::SecurityGroupIngress
  AWS::EC2::SecurityGroupEgress
).each do |resource_must_have_properties|
  fatal_violation ".Resources[] | select(.Type == \"#{resource_must_have_properties}\" and .Properties == null)" do |resource|
    message('fatal', "#{resource_must_have_properties} must have Properties", resource)
  end
end

fatal_violation '('\
                  '('\
                    '([..|.Ref?]|map(select(. != null)) +  [..|."Fn::GetAtt"?[0]]|map(select(. != null)))'\
                  ') '\
                  '- '\
                  '('\
                    '["AWS::AccountId","AWS::StackName","AWS::Region","AWS::StackId","AWS::NoValue"] + '\
                    '([.Resources|keys]|flatten) + '\
                    '(if .Parameters? then ([.Parameters|keys]|flatten) else [] end)'\
                  ')'\
                ')|'\
                'if length==0 then false else . end' do |danglers|
  message('fatal', 'All Ref and Fn::GetAtt must reference existing logical resource ids', danglers)
end

