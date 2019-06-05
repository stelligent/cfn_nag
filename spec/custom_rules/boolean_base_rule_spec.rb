require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/boolean_base_rule'

describe BooleanBaseRule do
  describe '#audit' do
    it 'raises an error when properties are not set' do
      expect do
        BooleanBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns violation when boolean value is false' do
      base_rule = BooleanBaseRule.new
      base_rule.instance_eval do
        def rule_id
          'F3333'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::EFS::FileSystem'
        end

        def boolean_property
          :encrypted
        end
      end

      expect(base_rule).to receive(:boolean_property).and_return(:encrypted)
      expect(base_rule).to receive(:resource_type).and_return('AWS::EFS::FileSystem')

      cfn_model = CfnParser.new.parse read_test_template 'json/efs/filesystem_with_encryption_false.json'

      expected_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[filesystem])

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when boolean value is true' do
      base_rule = BooleanBaseRule.new
      base_rule.instance_eval do
        def rule_id
          'F3333'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::EFS::FileSystem'
        end

        def boolean_property
          :encrypted
        end
      end

      expect(base_rule).to receive(:boolean_property).and_return(:encrypted)
      expect(base_rule).to receive(:resource_type).and_return('AWS::EFS::FileSystem')

      cfn_model = CfnParser.new.parse read_test_template 'json/efs/filesystem_with_encryption.json'

      expect(base_rule.audit(cfn_model)).to be nil
    end
  end
end
