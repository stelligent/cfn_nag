require 'spec_helper'

describe 'cfn_nag_rules --version', end_to_end: true do
  context 'when ensuring the local gem is installed' do
    it 'equals 0.0.01' do
      expect { system %( cfn_nag_rules --version ) }
        .to output(a_string_matching('0.0.01'))
        .to_stdout_from_any_process
    end
  end
  context 'when checking for a proper semantic version' do
    it 'matches the correct pattern' do
      expect { system %( cfn_nag_rules --version ) }
        .to output(a_string_matching(/\d.\d.\d/))
        .to_stdout_from_any_process
    end
    it 'does not match an incorrect pattern' do
      expect { system %( cfn_nag_rules --version ) }
        .not_to output(a_string_matching(/\d.\d.\d.\d/))
        .to_stdout_from_any_process
    end
  end
end
