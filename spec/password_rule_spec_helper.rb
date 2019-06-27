def file_path_prefix(resource_type, test_template_type)
  resource_name = resource_type.sub('AWS::', '').gsub('::', '_').downcase
  path_prefix = test_template_type +
                '/' +
                resource_name +
                '/' +
                resource_name +
                '_'
  path_prefix
end

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

def context_return_value(desired_test_result)
  if desired_test_result == 'fail'
    'returns offending logical resource id'
  else
    'returns empty list'
  end
end

def run_test(resource_type, password_property, test_template_type, test_description, desired_test_result)
  file_path = file_path_prefix(resource_type, test_template_type) +
              password_property.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase +
              '_' +
              test_description.to_s.gsub(' ', '_').downcase +
              '.' +
              test_template_type

  expected_logical_resource_ids =
    if desired_test_result == 'fail'
      [resource_type.sub('AWS::', '').gsub('::', '')]
    else
      expected_logical_resource_ids = []
    end

  cfn_model = CfnParser.new.parse read_test_template(file_path)

  actual_logical_resource_ids = described_class.new.audit_impl cfn_model

  expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
end
