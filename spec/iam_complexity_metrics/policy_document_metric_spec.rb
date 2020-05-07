require 'cfn-nag/iam_complexity_metric/policy_document_metric'
require 'cfn-model/model/policy_document'

describe PolicyDocumentMetric do
  context 'one statement' do
    it 'metric matches the one statement metric' do
      statement = Statement.new
      statement.effect = 'Deny'
      statement.actions = ['fred:YellAtDino']
      statement.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

      policy_document = PolicyDocument.new
      policy_document.statements += [
        statement
      ]

      actual_metric = PolicyDocumentMetric.new.metric policy_document
      expected_metric = 2
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'two statements' do
    it 'metric matches the two statements metric' do
      statement1 = Statement.new
      statement1.effect = 'Allow'
      statement1.actions = ['fred:YellAtDino']
      statement1.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

      statement2 = Statement.new
      statement2.effect = 'Allow'
      statement2.actions = ['fred:YellAtDino2']
      statement2.resources = ['arn:aws:fred:us-east-1:3333333333:dino2']

      policy_document = PolicyDocument.new
      policy_document.statements += [
        statement1,
        statement2
      ]

      actual_metric = PolicyDocumentMetric.new.metric policy_document
      expected_metric = 2
      expect(actual_metric).to eq(expected_metric)
    end
  end
end
