require 'spec_helper'

describe 'cfn_nag_scan template file input', end_to_end: true do
  context 'when reading in a template file with 1 failure' do
    test_template = 'spec/test_templates/e2e/ElastiCache.template'

    it 'prints out a failure count of 1' do
      expect { system %( cfn_nag_scan -i #{test_template} ) }
        .to output(a_string_including('Failures count: 1'))
        .to_stdout_from_any_process
    end

    it 'prints out a warning count of 2' do
      expect { system %( cfn_nag_scan -i #{test_template} ) }
        .to output(a_string_including('Warnings count: 2'))
        .to_stdout_from_any_process
    end
  end

  context 'when outputing in the default format, txt' do
    test_template = 'spec/test_templates/e2e/ElastiCache.template'
    it 'actually outputs as one big string' do
      stdout, stderr, status = Open3.capture3("cfn_nag_scan -i #{test_template}")

      expect(stdout).to be_an_instance_of(String)
    end
  end
  context 'when outputing to json' do
    test_template = 'spec/test_templates/e2e/ElastiCache.template'
    it 'actually outputs in JSON format' do
      stdout, stderr, status = Open3.capture3("cfn_nag_scan -i #{test_template} -o json")

      expect(JSON.parse(stdout)).to be_an_instance_of(Array)
    end
  end
end
