Feature:
  As a Dev(Sec)Ops engineer or security auditor
  I would like to look for bad IAM policies in Cloudformation JSON template
  So that I can have very fast feedback about potential security problems

Scenario: An IAM role is created with a statement with a full wildcard Action in its trust policy
  Given a Cloudformation template that creates an IAM role with a statement with a full wildcard Action in trust policy
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM role is created with a statement with a full wildcard Action in its permissions policy
  Given a Cloudformation template that creates an IAM role with a statement with a full wildcard Action in permissions policy
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM role is created with a statement with a full wildcard Resource
  Given a Cloudformation template that creates an IAM role with a statement with a full wildcard Resource
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM policy is created with a resource with a full wildcard Action
  Given a Cloudformation template that creates an IAM policy with a statement with a full wildcard Action
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM policy is created with a statement with a full wildcard Resource
  Given a Cloudformation template that creates an IAM policy with a statement with a full wildcard Resource
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM managed policy is created with a resource with a full wildcard Action
  Given a Cloudformation template that creates an IAM managed policy with a statement with a full wildcard Action
   When analyzing the template
   Then a violation is flagged

Scenario: An IAM managed policy is created with a statement with a full wildcard Resource
  Given a Cloudformation template that creates an IAM managed policy with a statement with a full wildcard Resource
   When analyzing the template
   Then a violation is flagged