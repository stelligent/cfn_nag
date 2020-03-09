require 'spec_helper'
require 'cfn-nag/rule_repos/s3_based_rule_repo'

class_code = <<END
require 'cfn-nag/violation'
require 'cfn-nag/custom_rules/base'

class FooRule < BaseRule
  def rule_text
    'No foos allowed'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F9993'
  end

  def audit_impl(cfn_model)
    violating_workspaces = cfn_model.resources_by_type('AWS::WorkSpaces::Workspace')

    violating_workspaces.map(&:logical_resource_id)
  end
end
END

describe S3BucketBasedRuleRepo do
  before(:each) do
    @s3_bucket_based_rule_repo = S3BucketBasedRuleRepo.new(
      s3_bucket_name: 'cfn-nag-rules',
      prefix: '/rules'
    )
  end

  after(:each) do
    @s3_bucket_based_rule_repo.nuke_cache
  end

  context 'prefix with leading slash' do
    # Bucket.objects(prefix: '/foo') won't match foo/whatever
    it 'strips the leading slash' do
      expect(@s3_bucket_based_rule_repo.prefix).to eq 'rules'
    end
  end

  context 'empty bucket' do
    it 'returns no rules' do
      expect(@s3_bucket_based_rule_repo).to receive(:index).and_return([])

      rule_registry = @s3_bucket_based_rule_repo.discover_rules
      expect(rule_registry.rule_classes.size).to eq(0)
    end
  end

  context 'bucket with *Rule.rb in prefix' do
    context 'cache miss' do
      it 'returns file from S3' do
        expect(@s3_bucket_based_rule_repo).to receive(:index).and_return(%w[rules/FooRule.rb])
        expect(@s3_bucket_based_rule_repo).to receive(:cache_miss).and_return(class_code)

        rule_registry = @s3_bucket_based_rule_repo.discover_rules

        actual_class_names = rule_registry.rule_classes.map { |rule_class| rule_class.name }
        expect(actual_class_names.to_a).to eq(['FooRule'])
      end
    end

    context 'cache hit' do
      it 'returns local file' do
        expect(@s3_bucket_based_rule_repo).to receive(:index).exactly(2).times.and_return(%w[rules/FooRule.rb])
        expect(@s3_bucket_based_rule_repo).to receive(:cache_miss).and_return(class_code)

        @s3_bucket_based_rule_repo.discover_rules

        allow(@s3_bucket_based_rule_repo).to receive(:cache_miss).and_return('garbage')

        rule_registry = @s3_bucket_based_rule_repo.discover_rules

        actual_class_names = rule_registry.rule_classes.map { |rule_class| rule_class.name }
        expect(actual_class_names.to_a).to eq(['FooRule'])
      end
    end
  end
end