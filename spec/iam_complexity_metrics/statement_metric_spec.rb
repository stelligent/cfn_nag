require 'cfn-nag/iam_complexity_metric/statement_metric'
require 'cfn-model/model/statement'

describe StatementMetric do
  describe '#metric' do
    context 'simple statement' do
      it 'returns 1' do
        statement = Statement.new
        statement.effect = 'Allow'
        statement.actions = ['fred:YellAtDino']
        statement.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 1
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'deny statement' do
      it 'returns 2' do
        statement = Statement.new
        statement.effect = 'Deny'
        statement.actions = ['fred:YellAtDino']
        statement.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 2
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Deny + notaction statement' do
      it 'returns 3' do
        statement = Statement.new
        statement.effect = 'Deny'
        statement.not_actions = ['fred:YellAtDino']
        statement.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 3
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'NotResource statement' do
      it 'returns 3' do
        statement = Statement.new
        statement.effect = 'Allow'
        statement.actions = ['fred:YellAtDino']
        statement.not_resources = ['arn:aws:fred:us-east-1:3333333333:dino']

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 2
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context '5 unique services mentioned in Resource' do
      it 'returns .1' do
        statement = Statement.new
        statement.effect = 'Allow'
        statement.actions = ['fred:YellAtDino']
        statement.resources = %w[
          arn:aws:fred:us-east-1:3333333333:dino
          arn:aws:wilma:us-east-1:3333333333:dino
          arn:aws:wilma:us-east-1:3333333333:dino
          arn:aws:zebra:us-east-1:3333333333:dino
          arn:aws:alpha:us-east-1:3333333333:dino
          arn:aws:beta:us-east-1:3333333333:dino
        ]

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 13
        expect(actual_metric).to eq(expected_metric)
      end
    end

    context 'Action and Resource services not aligned' do
      it 'returns .1' do
        statement = Statement.new
        statement.effect = 'Allow'
        statement.actions = %w[
          fred:YellAtDino
          wilma:YellAtFred
          zeta:BarkAtMoon
          alpha:EatCereal
        ]
        statement.resources = %w[
          arn:aws:fred:us-east-1:3333333333:dino
          arn:aws:wilma:us-east-1:3333333333:dino
          arn:aws:wilma:us-east-1:3333333333:dino
          arn:aws:zebra:us-east-1:3333333333:dino
          arn:aws:alpha:us-east-1:3333333333:dino
          arn:aws:beta:us-east-1:3333333333:dino
        ]

        actual_metric = StatementMetric.new.metric statement
        expected_metric = 13
        expect(actual_metric).to eq(expected_metric)
      end
    end
  end

  context 'wildcard action statement' do
    it 'returns 1' do
      statement = Statement.new
      statement.effect = 'Allow'
      statement.actions = ['*']
      statement.resources = ['arn:aws:fred:us-east-1:3333333333:dino']

      actual_metric = StatementMetric.new.metric statement
      expected_metric = 1
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'wildcard resource statement' do
    it 'returns 1' do
      statement = Statement.new
      statement.effect = 'Allow'
      statement.actions = ['fred:YellAtDino']
      statement.resources = ['*']

      actual_metric = StatementMetric.new.metric statement
      expected_metric = 1
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'admin statement' do
    it 'returns 1' do
      statement = Statement.new
      statement.effect = 'Allow'
      statement.actions = ['*']
      statement.resources = ['*']

      actual_metric = StatementMetric.new.metric statement
      expected_metric = 1
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'multiple service actions with wildcard resource' do
    it 'returns 2' do
      statement = Statement.new
      statement.effect = 'Allow'
      statement.actions = %w[route53resolver:* ec2:DescribeSubnets ec2:CreateNetworkInterface ec2:DeleteNetworkInterface ec2:ModifyNetworkInterfaceAttribute ec2:DescribeNetworkInterfaces ec2:CreateNetworkInterfacePermission ec2:DescribeSecurityGroups ec2:DescribeVpcs]
      statement.resources = ['*']

      actual_metric = StatementMetric.new.metric statement
      expected_metric = 3
      expect(actual_metric).to eq(expected_metric)
    end
  end

  context 'multiple service actions with wildcard resource' do
    it 'returns 2' do
      statement = Statement.new
      statement.effect = 'Allow'
      statement.actions = %w[route53resolver:* ec2:DescribeSubnets ec2:CreateNetworkInterface ec2:DeleteNetworkInterface ec2:ModifyNetworkInterfaceAttribute ec2:DescribeNetworkInterfaces ec2:CreateNetworkInterfacePermission ec2:DescribeSecurityGroups ec2:DescribeVpcs]
      statement.resources = %w[
        arn:aws:ec2:us-east-1:3333333333:dino
        arn:aws:route53resolver:us-east-1:3333333333:dino2
        *
      ]

      actual_metric = StatementMetric.new.metric statement
      expected_metric = 4
      expect(actual_metric).to eq(expected_metric)
    end
  end
end