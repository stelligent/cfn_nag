require 'spec_helper'
require 'cfn_nag'


describe CfnNag do
  before(:all) do
    CfnNag::configure_logging({debug: false})
    @cfn_nag = CfnNag.new
  end

  context 'when illegal json is input' do
    it 'fails fast' do
      template_name = 'rubbish.json'
      expect {
        @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      }.to raise_error 'not even legit JSON'
    end
  end

  context 'when resource are missing' do
    it 'flags a violation' do
      template_name = 'no_resources.json'
      begin
        @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
        fail 'should have exited'
      rescue SystemExit

      end
    end
  end
  context 'when sg properties are missing' do

    it 'flags a violation' do
      template_name = 'sg_missing_properties.json'
      begin
        @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
        fail 'should have exited'
      rescue SystemExit

      end
    end
  end

  context 'when egress is empty' do

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      violation_count = @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 1
    end
  end

  context 'when egress is empty' do

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      violation_count = @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 1
    end
  end

  context 'when inline ingress is open to world is empty and two egress are missing' do
    it 'flags a violation' do
      template_name = 'two_security_group_two_cidr_ingress.json'

      violation_count = @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 2
    end
  end

  context 'when has multiple inline egress rules' do

    it 'passes validation' do
      template_name = 'multiple_inline_egress.json'

      violation_count = @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 0
    end
  end

  context 'when inline iam user has no group membership' do

    it 'flags a violation' do
      template_name = 'iam_user_with_no_group.json'

      violation_count = @cfn_nag.audit(input_json_path: File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 1
    end
  end
end
