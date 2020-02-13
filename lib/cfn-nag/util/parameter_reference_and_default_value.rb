# frozen_string_literal: true

# Determines if a CloudFormation Resource's property is a Hash && a Reference
# and returns true if the referenced Parameter exists
# Args:
#   `resource`: CloudFormation resource as cfn_model object.
#   `property`: Property field within CloudFormation resource.
def property_a_param_ref?(resource, property)
  if property.is_a?(Hash) && property.key?('Ref')
    referenced_name = property['Ref']
    !resource.cfn_model.parameters[referenced_name].nil?
  end
end

# Returns the 'Default' value of the the Parameter being referenced. If there is no Default value,
# then it returns a 'nil' value.
# Args:
#   `resource`: CloudFormation resource as cfn_model object.
#   `property`: Property field within CloudFormation resource.
def get_default_param_value(resource, property)
  if resource.cfn_model.parameters[property['Ref']].default.nil?
    nil
  else
    resource.cfn_model.parameters[property['Ref']].default
  end
end
