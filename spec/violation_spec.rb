require 'cfn-nag/violation'

describe Violation do
  describe '#to_s' do
    it 'emits attributes' do
      violation = Violation.new(id: 'F99',
                                name: 'MyRule',
                                type: Violation::FAILING_VIOLATION,
                                message: 'EBS volume should have server-side encryption enabled',
                                logical_resource_ids: %w[NewVolume1 NewVolume2])
      expect(violation.to_s).to eq 'F99 MyRule FAIL EBS volume should have server-side encryption enabled ["NewVolume1", "NewVolume2"]'
    end
  end

  describe '#==' do
    context 'unequal' do
      it 'return false' do
        v1 = Violation.new(id: 'F1',
                           name: 'MyRule',
                           type: Violation::FAILING_VIOLATION,
                           message: 'EBS volume should have server-side encryption enabled',
                           logical_resource_ids: %w[NewVolume1 NewVolume2])

        v2 = Violation.new(id: 'F2',
                           name: 'MyRule2',
                           type: Violation::FAILING_VIOLATION,
                           message: 'EBS volume should have server-side encryption enabled',
                           logical_resource_ids: %w[NewVolume1 NewVolume2])

        expect(v1).to_not eq v2
      end
    end

    context 'equal' do
      it 'return true' do
        v1 = Violation.new(id: 'F1',
                           name: 'MyRule',
                           type: Violation::FAILING_VIOLATION,
                           message: 'EBS volume should have server-side encryption enabled',
                           logical_resource_ids: %w[NewVolume1 NewVolume2])

        v2 = Violation.new(id: 'F1',
                           name: 'MyRule',
                           type: Violation::FAILING_VIOLATION,
                           message: 'EBS volume should have server-side encryption enabled',
                           logical_resource_ids: %w[NewVolume1 NewVolume2])

        expect(v1).to eq v2
      end
    end
  end

  describe '#count_warnings' do
    context 'zero warnings' do
      it 'returns 0' do
        violations = [
          Violation.new(id: 'F1',
                        name: 'MyRule',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled',
                        logical_resource_ids: %w[NewVolume1 NewVolume2]),
          Violation.new(id: 'F2',
                        name: 'MyRule2',
                        type: Violation::FAILING_VIOLATION,
                        message: 'Bark at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3])
        ]
        expect(Violation.count_warnings(violations)).to eq 0
      end
    end

    context 'two warnings with three resource id and two failures' do
      it 'returns 3' do
        violations = [
          Violation.new(id: 'F1',
                        name: 'MyRule',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled',
                        logical_resource_ids: %w[NewVolume1 NewVolume2]),
          Violation.new(id: 'F2',
                        name: 'MyRule2',
                        type: Violation::FAILING_VIOLATION,
                        message: 'Bark at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3]),
          Violation.new(id: 'W2',
                        name: 'MyRule3',
                        type: Violation::WARNING,
                        message: 'Moo at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3]),
          Violation.new(id: 'W3',
                        name: 'MyRule4',
                        type: Violation::WARNING,
                        message: 'Moo at the moon2',
                        logical_resource_ids: %w[NewVolume3])

        ]
        expect(Violation.count_warnings(violations)).to eq 3
      end
    end

    context 'warning with no resource ids' do
      it 'returns 1' do
        violations = [
          Violation.new(id: 'W3',
                        name: 'MyRule',
                        type: Violation::WARNING,
                        message: 'Moo at the moon2',
                        logical_resource_ids: [])

        ]
        expect(Violation.count_warnings(violations)).to eq 1
      end
    end
  end

  describe '#count_failures' do
    context 'zero failures' do
      it 'returns 0' do
        violations = [
          Violation.new(id: 'W1',
                        name: 'MyRule',
                        type: Violation::WARNING,
                        message: 'Bark at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3]),
          Violation.new(id: 'W2',
                        name: 'MyRule2',
                        type: Violation::WARNING,
                        message: 'Moo at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3])
        ]
        expect(Violation.count_failures(violations)).to eq 0
      end
    end

    context 'two failures with two elements and one warning' do
      it 'returns 4' do
        violations = [
          Violation.new(id: 'F1',
                        name: 'MyRule',
                        type: Violation::FAILING_VIOLATION,
                        message: 'EBS volume should have server-side encryption enabled',
                        logical_resource_ids: %w[NewVolume1 NewVolume2]),
          Violation.new(id: 'F2',
                        name: 'MyRule2',
                        type: Violation::FAILING_VIOLATION,
                        message: 'Bark at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3]),
          Violation.new(id: 'W2',
                        name: 'MyRule3',
                        type: Violation::WARNING,
                        message: 'Moo at the moon',
                        logical_resource_ids: %w[NewVolume2 NewVolume3])
        ]
        expect(Violation.count_failures(violations)).to eq 4
      end
    end

    context 'failure with no resource ids' do
      it 'returns 1' do
        violations = [
          Violation.new(id: 'F3',
                        name: 'MyRule',
                        type: Violation::FAILING_VIOLATION,
                        message: 'Moo at the moon2',
                        logical_resource_ids: [])

        ]
        expect(Violation.count_failures(violations)).to eq 1
      end
    end
  end
  describe '#fatal_violation' do
    context 'generates fatal violation' do
      it 'returns violation' do
        fatal_violation = Violation.fatal_violation('Bad Moon')

        expect(fatal_violation.id).to eq 'FATAL'
        expect(fatal_violation.name).to eq 'system'
        expect(fatal_violation.type).to eq Violation::FAILING_VIOLATION
      end
    end
  end
end
