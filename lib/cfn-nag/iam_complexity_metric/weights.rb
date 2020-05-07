# frozen_string_literal: true

module Weights
  def weights
    {
      Base_Statement: 1,
      Allow: 0,
      Deny: 1,
      NotAction: 1,
      NotResource: 1,
      Mixed_Wildcard: 1,

      Extra_Service: 2,
      Resource_Action_NotAligned: 1,

      Condition: 2,
      IfExists: 1,
      Null: 1,
      PolicyVariables: 1
    }
  end
end
