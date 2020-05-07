# frozen_string_literal: true

require_relative 'statement_metric'

class PolicyDocumentMetric
  def metric(policy_document)
    policy_document.statements.reduce(0) do |aggregate, statement|
      aggregate + StatementMetric.new.metric(statement)
    end
  end
end
