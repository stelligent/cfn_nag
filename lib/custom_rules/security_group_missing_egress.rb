require_relative '../violation'

class SecurityGroupMissingEgressRule

  def audit(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      if security_group.egress_rules.size == 0
        logical_resource_ids << security_group.logical_resource_id
      end
    end

    if logical_resource_ids.size > 0
      Violation.new(type: Violation::FAILING_VIOLATION,
                    message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                    logical_resource_ids: logical_resource_ids)
    else
      nil
    end
  end
end