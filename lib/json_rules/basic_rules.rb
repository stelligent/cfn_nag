fatal_assertion '.Resources|length > 0' do
  message('fatal', 'Must have at least 1 resource')
end

fatal_violation '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and .Properties == null)' do |security_groups|
  message('fatal', 'Security Groups must have Properties', security_groups)
end

#use recurse to find all Ref and then cross-reference against .Resources|keys