Feature: Explicit Rule Suppression per Resource
  As a devops engineer
  I want to suppress one or more specific violations on a particular resource
  So that in cases where a violation is not appropriate - developers don't tune out from the noise

  I want the default mode of operation to allow suppression, but to provide a flag to ignore
  suppression in the case where a centrally controlled body uses specific profiles and doesn't want to allow
  end-runs around them.

  I want to be able to optionally emit suppressed resources/rules.

Scenario: No cfn_nag key in Metadata attribute
  Given a cloudformation resource with no Metadata/cfn_nag attribute
  When cfn_nag analyzes the resource
  Then it will apply all rules in the current profile

Scenario: Suppression of explicit cfn_nag rules
  Given a cloudformation resource that includes the Metadata key:
    | cfn_nag:                                                             |
    |   rules_to_suppress:                                                 |
    |     - id: W2                                                         |
    |       reason: This security group is attached to internet-facing ELB |
    And the allow_suppressions mode is true
   When cfn_nag analyzes the resource
   Then it will not apply W2 to the resource with the Metadata key

Scenario: Denying suppression of rules
  Given a cloudformation resource that includes a rule suppression
    And the allow_suppressions mode is false
   When cfn_nag analyzes the resource
   Then it will apply W2 to the resource with the Metadata key (all rules in the current profile)

Scenario: Missing rule identifier in metadata for suppressing cfn_nag rules
  Given a cloudformation resource with cfn_nag key that doesn't include id:
    | cfn_nag:                                                             |
    |   rules_to_suppress: junk                                            |

    | cfn_nag:                                                             |
    |   rules_to_suppress:                                                 |
    |     - reason: This security group is attached to internet-facing ELB |
  When cfn_nag analyzes the resource
  Then it will emit an error to stderr explaining that the metadata is malformed