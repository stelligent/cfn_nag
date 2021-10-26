require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'iam role has wildcard that is behind a second-level ref', :moo9 do
    it 'flags a violation' do
      template_name = 'yaml/iam_role/embedded_ref.yml'

      expected_violations = [
        IamRoleWildcardResourceOnPermissionsPolicyRule.new.violation(%w[HelperRole], [7], ["resource"])
      ]

      actual_violations = @cfn_nag.audit(
        cloudformation_string: IO.read(test_template_path(template_name)),
        parameter_values_string: '{"Parameters":{"Resource":"*"}}'
      )
      expect(actual_violations[:violations]).to eq expected_violations
    end
  end
end
