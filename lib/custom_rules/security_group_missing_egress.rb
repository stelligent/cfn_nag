class SecurityGroupMissingEgressRule
  def audit(cfn_model)
    violation_found = false

    cfn_model.security_groups.each do |security_group|
      if security_group.egress_rules.size == 0
        puts "VIOLATION: Missing egress rule means all traffic is allowed outbound: #{security_group}"
        violation_found = true
      end
    end
    not violation_found
  end
end