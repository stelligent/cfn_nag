require 'cfn-nag/rule_repository_loader'
require 'cfn-nag/rule_repo_exception'
require 'cfn-nag/rule_registry'
require 'cfn-nag/rule_repos/s3_based_rule_repo'

class FakeClass1
end

class FakeClass2
end

describe RuleRepositoryLoader do
  context 'list of rule repositories' do
    it 'returns a registry with the extra classes' do
      definition1 = <<END
---
repo_class_name: S3BucketBasedRuleRepo
repo_arguments:
  s3_bucket_name: cfn-nag-rules
  prefix: /rules
END
      definition2 = <<END
---
repo_class_name: S3BucketBasedRuleRepo
repo_arguments:
  s3_bucket_name: cfn-nag-rules2
  prefix: /rules2
END
      rule_repository_definitions = [
        definition1,
        definition2
      ]
      rule_registry = RuleRegistry.new

      first_rule_registry = RuleRegistry.new
      first_rule_registry.rule_classes << FakeClass1

      second_rule_registry = RuleRegistry.new
      second_rule_registry.rule_classes << FakeClass2

      first_rule_repo = double('S3BucketBasedRuleRepo1')
      expect(first_rule_repo).to receive(:discover_rules).and_return(first_rule_registry)

      second_rule_repo = double('S3BucketBasedRuleRepo2')
      expect(second_rule_repo).to receive(:discover_rules).and_return(second_rule_registry)

      expect(S3BucketBasedRuleRepo).to receive(:new)
                                         .with({s3_bucket_name:'cfn-nag-rules', prefix: '/rules'})
                                         .and_return(first_rule_repo)
      expect(S3BucketBasedRuleRepo).to receive(:new)
                                         .with({s3_bucket_name:'cfn-nag-rules2', prefix: '/rules2'})
                                         .and_return(second_rule_repo)

      rule_registry = RuleRepositoryLoader.new.merge rule_registry, rule_repository_definitions
      actual_rule_classes = rule_registry.rule_classes.map { |rule_class| rule_class.name }
      expected_rule_classes = %w(FakeClass1 FakeClass2)

      expect(actual_rule_classes).to eq(expected_rule_classes)
    end
  end

  context 'missing repo_class_name' do
    it 'raises an exception' do
      definition1 = <<END
---
repo_arguments:
  s3_bucket_name: cfn-nag-rules
  prefix: /rules
END

      rule_repository_definitions = [
        definition1
      ]
      rule_registry = RuleRegistry.new

      expect {
        rule_registry = RuleRepositoryLoader.new.merge rule_registry, rule_repository_definitions
      }.to raise_error RuleRepoException
    end
  end

  context 'bogus repo_class_name' do
    it 'raises an exception' do
      definition1 = <<END
---
repo_class_name: NotARealClass
repo_arguments:
  s3_bucket_name: cfn-nag-rules
  prefix: /rules
END

      rule_repository_definitions = [
        definition1
      ]
      rule_registry = RuleRegistry.new

      expect {
        rule_registry = RuleRepositoryLoader.new.merge rule_registry, rule_repository_definitions
      }.to raise_error RuleRepoException
    end
  end
end
