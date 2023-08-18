require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

# Returns "violating map" of sublist properties that are
# truthy (boolean true)

class SubPropertyWithListTruthyValueBaseRule < BaseRule
  def resource_type
      raise 'must implement in subclass'
  end


  def sublist_property
      raise 'must implement in subclass'
  end


  def sub_property_name; end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type(resource_type)

    violating_resources = resources.select do |resource|
      begin
        truthy_subproperty_in_list(
          cfn_model, resource, sublist_property, sub_property_name
        )
      rescue
        false
      end
    end

    violating_resources.map(&:logical_resource_id)
  end


  private

  def truthy_subproperty_in_list(
    cfn_model, resource, sublist_property, sub_property_name
  )
    property_list = resource.send(sublist_property)
    return false unless property_list

    property_list.find do |property_element|
      sub_value = property_element[sub_property_name]
      truthy?(property_element[sub_property_name]) || property_element[sub_property_name].nil?
    end
  end

end
