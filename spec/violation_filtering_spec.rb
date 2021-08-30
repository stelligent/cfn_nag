require 'spec_helper'
require 'cfn-nag/violation_filtering'
require 'cfn-nag/violation'
require 'cfn-nag/rule_id_set'
require 'cfn-nag/profile_loader'
require 'cfn-nag/deny_list_loader'

include ViolationFiltering

describe ViolationFiltering do
  before(:all) do
    @violations = [
      Violation.new(id: 'F1',
                    type: Violation::FAILING_VIOLATION,
                    message: 'EBS volume should have server-side encryption enabled',
                    logical_resource_ids: %w[NewVolume1 NewVolume2]),

      Violation.new(id: 'F2',
                    type: Violation::FAILING_VIOLATION,
                    message: 'EBS volume should have server-side encryption enabled2',
                    logical_resource_ids: %w[NewVolume1 NewVolume2]),

      Violation.new(id: 'F3',
                    type: Violation::FAILING_VIOLATION,
                    message: 'EBS volume should have server-side encryption enabled3',
                    logical_resource_ids: %w[NewVolume1 NewVolume2])
    ]
  end

  context 'nil profile' do
    it 'filters nothing' do
      profile_definition = nil
      dontcare = nil

      actual_violations = filter_violations_by_profile(
        profile_definition: profile_definition,
        rule_definitions: dontcare,
        violations: @violations
        )
      expect(actual_violations).to eq @violations
    end
  end

  context 'nil deny list' do
    it 'filters nothing' do
      deny_list_definition = nil
      dontcare = nil

      actual_violations = filter_violations_by_deny_list(
        deny_list_definition: deny_list_definition,
        rule_definitions: dontcare,
        violations: @violations
      )
      expect(actual_violations).to eq @violations
    end
  end

  context 'violations X,Y,Z' do

    context 'profile with X,Y' do
      it 'returns violations X,Y' do
        profile = RuleIdSet.new
        profile.add_rule 'F1'
        profile.add_rule 'F2'

        mocked_profile_loader = double('profile_loader')
        expect(ProfileLoader).to receive(:new).and_return(mocked_profile_loader)
        expect(mocked_profile_loader).to receive(:load).and_return(profile)

        profile_definition = 'dontcare'
        dontcare = nil
        expected_violations = [
          Violation.new(id: 'F1',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled',
                        logical_resource_ids: %w[NewVolume1 NewVolume2]),

          Violation.new(id: 'F2',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled2',
                        logical_resource_ids: %w[NewVolume1 NewVolume2])
        ]
        actual_violations = filter_violations_by_profile(
          profile_definition: profile_definition,
          rule_definitions: dontcare,
          violations: @violations
        )
        expect(actual_violations).to eq expected_violations
      end
    end

    context 'deny list with Y,Z' do
      it 'returns violations X' do
        deny_list = RuleIdSet.new
        deny_list.add_rule 'F2'
        deny_list.add_rule 'F3'

        mocked_deny_list_loader = double('deny_list_loader')
        expect(DenyListLoader).to receive(:new).and_return(mocked_deny_list_loader)
        expect(mocked_deny_list_loader).to receive(:load).and_return(deny_list)

        deny_list_definition = 'dontcare'
        dontcare = nil
        expected_violations = [
          Violation.new(id: 'F1',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled',
                        logical_resource_ids: %w[NewVolume1 NewVolume2])
        ]
        actual_violations = filter_violations_by_deny_list(
          deny_list_definition: deny_list_definition,
          rule_definitions: dontcare,
          violations: @violations
        )
        expect(actual_violations).to eq expected_violations
      end
    end
  end
end
