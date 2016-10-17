Feature:
  As a Dev(Sec)Ops engineer or security auditor
  I would like to look for bad IAM policies in CloudFormation JSON template
  So that I can have very fast feedback about potential security problems

Scenario: An IAM user is created without a group
  Given a CloudFormation template that creates an IAM user without a group reference
    And without a "user group addition"
   When analyzing the template
   Then a violation is flagged that a user must belong to a group to ease permission management

Scenario: An IAM user is created with explicit policies
  Given a CloudFormation template that creates an IAM user explicit policies
  When analyzing the template
  Then a violation is flagged that policies should be against the group

Scenario: An IAM policy is created with direct relationship to an IAM user
  Given a CloudFormation template that creates an IAM policy with direct relationship to an IAM user
   When analyzing the template
   Then a violation is flagged that policies should be against the group

Scenario: An IAM managed policy is created with direct relationship to an IAM user
  Given a CloudFormation template that creates an IAM managed policy with direct relationship to an IAM user
   When analyzing the template
   Then a violation is flagged that policies should be against the group
