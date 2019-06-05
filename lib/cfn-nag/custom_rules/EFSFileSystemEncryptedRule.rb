# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class EFSFileSystemEncryptedRule < BooleanBaseRule
  def rule_text
    'EFS FileSystem should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F32'
  end

  def resource_type
    'AWS::EFS::FileSystem'
  end

  def boolean_property
    :encrypted
  end
end
