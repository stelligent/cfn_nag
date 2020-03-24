# Creates the path prefix using information provided from the
# resource_type & test_template_type
def file_path_prefix(resource_type, test_template_type)
  resource_name = resource_type.sub('AWS::', '').gsub('::', '_').downcase
  path_prefix = [
    test_template_type,
    resource_name,
    resource_name
  ].join('/') + '_'

  path_prefix
end

# Returns a string based on the value result of the rule test sets
def context_return_value(desired_test_result)
  raise 'desired_test_result value must be either "pass" or "fail"' unless
    %w[pass fail].include?(desired_test_result)

  if desired_test_result == 'fail'
    'returns offending logical resource id'
  else
    'returns empty list'
  end
end

# Creates the string name for the rule
def rule_name(resource_type, property_name, sub_property_name)
  sub_property_value = sub_property_name.nil? ? '' : sub_property_name

  [
    resource_type.sub('AWS', '').gsub('::', ''),
    property_name,
    sub_property_value,
    'Rule'
  ].join
end

# Creates full file path string
def file_path(
  resource_type, test_template_type, property_name, sub_property_name,
  test_description
)
  if sub_property_name.nil?
    _nil_sub_property_name_file_path(
      resource_type, test_template_type, property_name, test_description
    )
  else
    _not_nil_sub_property_name_file_path(
      resource_type, test_template_type, property_name,
      sub_property_name, test_description
    )
  end
end

# Creates the logic for the file path if sub_property_name is nil
def _nil_sub_property_name_file_path(
  resource_type, test_template_type, property_name, test_description
)
  [
    file_path_prefix(resource_type, test_template_type),
    property_name.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase,
    '_',
    test_description.to_s.gsub(' ', '_').downcase,
    '.',
    test_template_type
  ].join
end

# Creates the logic for the file path if sub_property_name is present
def _not_nil_sub_property_name_file_path(
  resource_type, test_template_type, property_name,
  sub_property_name, test_description
)
  [
    file_path_prefix(resource_type, test_template_type),
    property_name.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase,
    '_',
    sub_property_name.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase,
    '_',
    test_description.to_s.gsub(' ', '_').downcase,
    '.',
    test_template_type
  ].join
end

# Returns an array based on the value result of the rule test sets
def expected_logical_resource_ids(desired_test_result, resource_type)
  raise 'desired_test_result value must be either "pass" or "fail"' unless
    %w[pass fail].include?(desired_test_result)

  if desired_test_result == 'fail'
    [resource_type.sub('AWS::', '').gsub('::', '')]
  else
    []
  end
end

# Run the spec test
def run_test(
  resource_type, property_name, sub_property_name, test_template_type,
  test_description, desired_test_result
)
  cfn_model =
    CfnParser.new.parse read_test_template(
      file_path(
        resource_type, test_template_type, property_name,
        sub_property_name, test_description
      )
    )

  actual_logical_resource_ids = described_class.new.audit_impl cfn_model

  expect(actual_logical_resource_ids).to eq \
    expected_logical_resource_ids(desired_test_result, resource_type)
end
