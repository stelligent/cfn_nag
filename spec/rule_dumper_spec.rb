require 'cfn-nag/rule_dumper'

describe CfnNagRuleDumper do
  context 'no profile' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new
    end

    it 'emits list of rules' do
      @rule_dumper.dump_rules
    end
  end

  context 'simple profile' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new profile_definition: "F1\nF9\n",
                                          rule_directory: nil
    end

    it 'emits list of rules' do
      expected_output = <<END
WARNING VIOLATIONS:

FAILING VIOLATIONS:
F1 EBS volume should have server-side encryption enabled
F9 S3 Bucket policy should not allow Allow+NotPrincipal
END

      expect do
        @rule_dumper.dump_rules
      end.to output(expected_output).to_stdout
    end
  end
end
