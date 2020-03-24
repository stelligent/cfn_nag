# Name of the password tests to run, matching the test teplates file names
# States whether the test should be a pass or fail
def password_rule_test_sets
  {
    'not set': 'pass',
    'parameter with NoEcho': 'pass',
    'parameter with NoEcho and Default value': 'fail',
    'parameter as a literal in plaintext': 'fail',
    'as a literal in plaintext': 'fail',
    'from Secrets Manager': 'pass',
    'from Secure Systems Manager': 'pass',
    'from Systems Manager': 'fail'
  }
end

# Name of the missing property tests to run, matching the test teplates file names
# States whether the test should be a pass or fail
def missing_property_rule_test_sets
  {
    'not set': 'fail',
    'set': 'pass'
  }
end
