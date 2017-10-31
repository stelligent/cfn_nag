require 'spec_helper'
require 'json'
require 'plain_text_results'

describe PlainTextResults do
  context 'some results' do
    it 'emits a string' do
      audit_results = [
        {
          name: 'templates/fred1.json',
          audit_result: {
            failure_count: 1,
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
        }
      ]

      plain_text_audit_results = PlainTextResults.new.render audit_results
      puts plain_text_audit_results
      expect(plain_text_audit_results.class).to eq String
    end
  end
end