require 'spec_helper'
require 'cfn-nag/util/string_to_boolean'

describe 'to_boolean', :rule do

  context 'Strings map to boolean' do
    it 'given any true string, to_boolean returns true boolean' do
      %w[true TRUE tRUE True tRuE TrUe]
        .map { |x| to_boolean(x) }
        .map { |x| expect(x).to eq true }
    end

    it 'given any false string, to_boolean returns false boolean' do
      %w[false FALSE fALSE False fAlSe FaLsE]
        .map { |x| to_boolean(x) }
        .map { |x| expect(x).to eq false }
    end
  end
end
