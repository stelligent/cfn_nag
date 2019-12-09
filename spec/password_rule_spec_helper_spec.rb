require 'spec_helper'
require 'password_rule_spec_helper'

describe 'password_rule_spec_helper' do
  before(:all) do
    @resource_type = 'AWS::Foo::Bar'
    @password_property = 'Baz'
    @test_template_type = 'yaml'
  end

  context 'file_path_prefix' do
    it 'renders path prefix' do
      actual_aggregate_results =
        file_path_prefix(@resource_type, @test_template_type)
      expect(actual_aggregate_results).to eq 'yaml/foo_bar/foo_bar_'
    end
  end

  context 'password_rule_test_sets' do
    it 'is a hash' do
      actual_aggregate_results = password_rule_test_sets.is_a? Hash
      expect(actual_aggregate_results).to eq true
    end
  end

  context 'password_rule_test_sets' do
    it 'is a not a string' do
      actual_aggregate_results = password_rule_test_sets.is_a? String
      expect(actual_aggregate_results).to eq false
    end
  end

  context 'password_rule_test_sets' do
    it 'is a not an array' do
      actual_aggregate_results = password_rule_test_sets.is_a? Array
      expect(actual_aggregate_results).to eq false
    end
  end

  context 'context_return_value as "fail"' do
    it 'returns offending logical resource id' do
      actual_aggregate_results = context_return_value('fail')
      expect(actual_aggregate_results).to eq \
        'returns offending logical resource id'
    end
  end

  context 'context_return_value as "pass"' do
    it 'returns empty list' do
      actual_aggregate_results = context_return_value('pass')
      expect(actual_aggregate_results).to eq 'returns empty list'
    end
  end

  context 'context_return_value as "foo"' do
    it 'raises error' do
      expect { context_return_value('foo') }.to \
        raise_error('desired_test_result value must be either "pass" or "fail"')
    end
  end

  context 'rule_name with sub_property_name set' do
    before(:each) do
      @sub_property_name = 'Qux'
    end
    it 'renders rule name' do
      actual_aggregate_results = rule_name(
        @resource_type, @password_property, @sub_property_name
      )
      expect(actual_aggregate_results).to eq 'FooBarBazQuxRule'
    end
  end

  context 'rule_name with no sub_property_name set' do
    before(:each) do
      @sub_property_name = nil
    end
    it 'renders rule name' do
      actual_aggregate_results = rule_name(
        @resource_type, @password_property, @sub_property_name
      )
      expect(actual_aggregate_results).to eq 'FooBarBazRule'
    end
  end

  context 'file_path with sub_property_name set' do
    before(:each) do
      @sub_property_name = 'Qux'
    end
    it 'renders full test template file path' do
      actual_aggregate_results =
        file_path(@resource_type,
                  @test_template_type,
                  @password_property,
                  @sub_property_name,
                  'test template name')
      expect(actual_aggregate_results).to eq \
        'yaml/foo_bar/foo_bar_baz_qux_test_template_name.yaml'
    end
  end

  context 'file_path with no sub_property_name set' do
    before(:each) do
      @sub_property_name = nil
    end
    it 'renders full test template file path' do
      actual_aggregate_results =
        file_path(@resource_type,
                  @test_template_type,
                  @password_property,
                  @sub_property_name,
                  'test template name')
      expect(actual_aggregate_results).to eq \
        'yaml/foo_bar/foo_bar_baz_test_template_name.yaml'
    end
  end

  context 'expected_logical_resource_ids as "pass"' do
    it 'returns empty list' do
      actual_aggregate_results =
        expected_logical_resource_ids('pass', @resource_type)
      expect(actual_aggregate_results).to eq []
    end
  end

  context 'expected_logical_resource_ids as "fail"' do
    it 'returns offending resource id' do
      actual_aggregate_results =
        expected_logical_resource_ids('fail', @resource_type)
      expect(actual_aggregate_results).to eq ['FooBar']
    end
  end

  context 'expected_logical_resource_ids as "foo"' do
    it 'raises error' do
      expect { expected_logical_resource_ids('foo', @resource_type) }.to \
        raise_error('desired_test_result value must be either "pass" or "fail"')
    end
  end
end
