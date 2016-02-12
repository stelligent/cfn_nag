require 'spec_helper'
require 'cfn_nag'


describe CfnNag do

  context 'when illegal json is input' do
    before(:all) do
      CfnNag::configure_logging({debug: false})
      @cfn_nag = CfnNag.new
    end

    it 'fails fast' do
      template_name = 'rubbish.json'
      expect {
        @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      }.to raise_error 'not even legit JSON'
    end
  end

  context 'when resource are missing' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'flags a violation' do
      template_name = 'no_resources.json'
      begin
        @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
        fail 'should have exited'
      rescue SystemExit

      end
    end
  end
  context 'when sg properties are missing' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'flags a violation' do
      template_name = 'sg_missing_properties.json'
      begin
        @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
        fail 'should have exited'
      rescue SystemExit

      end
    end
  end

  context 'when egress is empty' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      violation_count = @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 1
    end
  end

  context 'when egress is empty' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      violation_count = @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 1
    end
  end

  context 'when inline ingress is open to world is empty and two egress are missing' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'flags a violation' do
      template_name = 'two_security_group_two_cidr_ingress.json'

      violation_count = @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 2
    end
  end

  context 'when has multiple inline egress rules' do
    before(:all) do
      @cfn_nag = CfnNag.new
    end

    it 'passes validation' do
      template_name = 'multiple_inline_egress.json'

      violation_count = @cfn_nag.audit(File.join(__dir__, 'test_templates', template_name))
      expect(violation_count).to eq 0
    end
  end
end
