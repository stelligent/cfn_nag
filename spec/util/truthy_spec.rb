require 'spec_helper'
require 'cfn-nag/util/truthy'

describe 'truthy', :rule do

  context 'Strings map to boolean' do
    it 'given any true string, to_boolean returns true boolean' do
      %w[true TRUE tRUE True tRuE TrUe]
        .map { |x| truthy?(x) }
        .map { |x| expect(x).to eq true }
    end

    it 'given any false string, to_boolean returns false boolean' do
      %w[false FALSE fALSE False fAlSe FaLsE]
        .map { |x| truthy?(x) }
        .map { |x| expect(x).to eq false }
    end
  end
end
