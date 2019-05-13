require 'spec_helper'

describe 'cfn_nag -d', end_to_end: true do
  context 'when debug logging is enabled' do
    it 'prints debug messages' do
      test_template = 'spec/test_templates/e2e/ElastiCache.template'

      expect { system %( cfn_nag -i #{test_template} -d) }
        .to output(a_string_starting_with('DEBUG'))
        .to_stdout_from_any_process
    end
  end
end
