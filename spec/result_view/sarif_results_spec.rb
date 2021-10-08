require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe SarifResults do
  # Method of suppressing stderr and stdout was found on StackOverflow here:
  # https://stackoverflow.com/a/22777806
  original_stderr = nil
  original_stdout = nil

  before(:all) do
    original_stderr = $stderr  # capture previous value of $stderr
    original_stdout = $stdout  # capture previous value of $stdout
    $stderr = StringIO.new     # assign a string buffer to $stderr
    $stdout = StringIO.new     # assign a string buffer to $stdout
    # $stderr.string             # return the contents of the string buffer if needed
    # $stdout.string             # return the contents of the string buffer if needed
  end

  after(:all) do
    $stderr = original_stderr  # restore $stderr to its previous value
    $stdout = original_stdout  # restore $stdout to its previous value
  end

  describe '#driver' do
    context 'with four rules' do
      before(:each) do
        @rules = [
          RuleDefinition.new(id: 'F1', name: 'Fail1', type: RuleDefinition::FAILING_VIOLATION, message: 'Bad Security Setting'),
          RuleDefinition.new(id: 'F2', name: 'Fail2', type: RuleDefinition::FAILING_VIOLATION, message: 'Missing Security Setting'),
          RuleDefinition.new(id: 'F3', name: 'Fail3', type: RuleDefinition::FAILING_VIOLATION, message: 'Invalid Security Setting'),
          RuleDefinition.new(id: 'F4', name: 'Fail4', type: RuleDefinition::FAILING_VIOLATION, message: 'Default Security Setting')
        ]
      end

      it 'should contain name, informationUri, semanticVersion and rules attributes' do
        sarif_driver = SarifResults.new.driver(@rules)

        expect(sarif_driver).to include(:name, :informationUri, :semanticVersion, :rules)
        expect(sarif_driver[:name]).to eq('cfn_nag')
        expect(sarif_driver[:informationUri]).to eq('https://github.com/stelligent/cfn_nag')
      end

      it 'should contain a driver with four rules' do
        sarif_driver = SarifResults.new.driver(@rules)

        expect(sarif_driver[:rules].length).to eq(4)
      end

      it 'should contain a rule with id, name, fullDescription' do
        sarif_driver = SarifResults.new.driver(@rules)

        expect(sarif_driver[:rules].first).to include(:id, :name, :fullDescription)
      end
    end
  end

  describe '#sarif_result' do
    context 'with single entry violation' do
      before(:each) do
        @violation = S3BucketPolicyWildcardActionRule.new.violation(['resource1'], [54])
      end

      it 'should return result object with ruleId, level, message and location attributes' do
        sarif_results = SarifResults.new.sarif_result(file_name: 'bob.txt', violation: @violation, index: 0)

        expect(sarif_results).to include(:ruleId, :level, :message, :locations)
        expect(sarif_results[:ruleId]).to eq(@violation.id)
        expect(sarif_results[:level]).to eq('error')
        expect(sarif_results[:message][:text]).to eq(@violation.message)
      end

      it 'should return one location with physical and logical sections' do
        sarif_results = SarifResults.new.sarif_result(file_name: 'bob.txt', violation: @violation, index: 0)

        expect(sarif_results[:locations].length).to eq(1)

        location = sarif_results[:locations].first

        expect(location).to include(:physicalLocation, :logicalLocations)

        expect(location[:physicalLocation]).to include(:artifactLocation, :region)
        expect(location[:physicalLocation][:artifactLocation]).to include(:uri)
        expect(location[:physicalLocation][:artifactLocation][:uri]).to eq('bob.txt')
        expect(location[:physicalLocation][:region][:startLine]).to eq(54)

        expect(location[:logicalLocations].length).to eq(1)
        expect(location[:logicalLocations].first).to include(:name)
        expect(location[:logicalLocations].first[:name]).to eq('resource1')
      end
    end

    context 'with multiple entry violation' do
      before(:each) do
        @violation = S3BucketPolicyWildcardActionRule.new.violation(['resource1', 'resource2'], [54, 1039])
      end

      it 'should return result object with ruleId, level, message and location attributes' do
        sarif_results = SarifResults.new.sarif_result(file_name: 'bob.txt', violation: @violation, index: 1)

        expect(sarif_results).to include(:ruleId, :level, :message, :locations)
        expect(sarif_results[:ruleId]).to eq(@violation.id)
        expect(sarif_results[:level]).to eq('error')
        expect(sarif_results[:message][:text]).to eq(@violation.message)
      end

      it 'should return one location with physical and logical sections' do
        sarif_results = SarifResults.new.sarif_result(file_name: 'bob.txt', violation: @violation, index: 1)

        expect(sarif_results[:locations].length).to eq(1)

        location = sarif_results[:locations].first

        expect(location).to include(:physicalLocation, :logicalLocations)

        expect(location[:physicalLocation]).to include(:artifactLocation, :region)
        expect(location[:physicalLocation][:artifactLocation]).to include(:uri)
        expect(location[:physicalLocation][:artifactLocation][:uri]).to eq('bob.txt')
        expect(location[:physicalLocation][:region][:startLine]).to eq(1039)

        expect(location[:logicalLocations].length).to eq(1)
        expect(location[:logicalLocations].first).to include(:name)
        expect(location[:logicalLocations].first[:name]).to eq('resource2')
      end
    end
  end

  describe '#sarif_level' do
    it 'should return warning type for warning rules' do
      expect(SarifResults.new.sarif_level(RuleDefinition::WARNING)).to eq('warning')
    end
    it 'should return error type for failing rules' do
      expect(SarifResults.new.sarif_level(RuleDefinition::FAILING_VIOLATION)).to eq('error')
    end

    it 'should return error type for other input' do
      expect(SarifResults.new.sarif_level(nil)).to eq('error')
      expect(SarifResults.new.sarif_level('bob')).to eq('error')
    end
  end
end