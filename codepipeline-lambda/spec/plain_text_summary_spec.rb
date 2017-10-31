require 'spec_helper'
require 'json'
require 'plain_text_summary'

describe PlainTextSummary do
  context 'some results' do
    it 'emits a string' do
      audit_results = [
        {
          name: 'templates/fred1.json',
          audit_result: {
            failure_count: 2,
            violations: [
              Violation.new(id: 'F1',
                            type: Violation::FAILING_VIOLATION,
                            message: 'EBS volume should have server-side encryption enabled',
                            logical_resource_ids: %w(NewVolume1 NewVolume2))
            ]
          }
        },
        {
          name: 'templates/fred2.json',
          audit_result: {
            failure_count: 0,
            violations: []
          }
        },
        {
          name: 'templates/fred3.json',
          audit_result: {
            failure_count: 0,
            violations: [
              Violation.new(id: 'F1',
                            type: Violation::WARNING,
                            message: 'EBS volume should have server-side encryption enabled',
                            logical_resource_ids: %w(NewVolume1))
            ]
          }
        },
        {
          name: 'templates/fred4.json',
          audit_result: {
            failure_count: 1,
            violations: [
              Violation.new(id: 'F1',
                            type: Violation::FAILING_VIOLATION,
                            message: 'EBS volume should have server-side encryption enabled',
                            logical_resource_ids: %w(NewVolume1))
            ]
          }
        },
      ]

      actual_summary = PlainTextSummary.new.render audit_results
      expected_summary = <<END
Failures count: 3
Warnings count: 1
END
      expect(actual_summary).to eq expected_summary
    end
  end
end