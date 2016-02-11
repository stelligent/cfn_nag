require 'spec_helper'
require 'cfn_nag'


describe CfnNag do

  context 'when illegal json is input' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'fails fast' do
      template_name = 'rubbish.json'
      expect {
        @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      }.to raise_error 'not even legit JSON'
    end
  end

  # context 'when sg properties are missing' do
  #   before(:all) do
  #     @cfn_nag = CfnNag.new
  #   end
  #
  #   it 'flags a violation' do
  #     template_name = 'sg_missing_properties.json'
  #     failure_count = @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
  #     expect(failure_count).to eq 1
  #   end
  # end
end
