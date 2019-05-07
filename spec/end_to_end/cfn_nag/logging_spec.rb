require 'spec_helper'

describe 'cfn_nag -d', end_to_end: true do
  context 'when debug logging is enabled' do
    it 'should log debug messages' do
      test_template = Dir.pwd + '/spec/aws_sample_templates/ElastiCache.template'
      stdout = Open3.capture3("cfn_nag -d #{test_template}")[0]

      expect(stdout).to start_with('DEBUG')
    end
  end
end
