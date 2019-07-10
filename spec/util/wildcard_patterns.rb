# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/util/wildcard_patterns'

describe 'wildcard_patterns', :rule do
  context 'Passing "front" pattern_types option' do
    it 'returns patterns with * at front' do
      expect(wildcard_patterns('test', pattern_types: ['front'])).to eq %w[test *test *est *st *t *]
    end
  end

  context 'Passing "back" pattern_types option' do
    it 'returns patterns with * at back' do
      expect(wildcard_patterns('test', pattern_types: ['back'])).to eq %w[test test* tes* te* t* *]
    end
  end

  context 'Passing "both" pattern option' do
    it 'returns patterns with * at front and back' do
      expect(wildcard_patterns('test', pattern_types: ['both'])).to eq %w[test *test* *tes* *te* *t* *est* *es* *e* *st* *s* *t* *]
    end
  end

  context 'Passing "front" and "back" pattern_types options' do
    it 'returns patterns with * at front and * at back' do
      expect(wildcard_patterns('test', pattern_types: %w[front back])).to eq %w[test *test *est *st *t test* tes* te* t* *]
    end
  end

  context 'Passing no pattern_types option' do
    it 'returns all patterns( front, back, both)' do
      expect(wildcard_patterns('test')).to eq %w[test *test *est *st *t test* tes* te* t* *test* *tes* *te* *t* *est* *es* *e* *st* *s* *t* *]
    end
  end
  context 'Passing an integer as the input "string"' do
    it 'returns valid results' do
      expect(wildcard_patterns(123)).to eq %w[123 *123 *23 *3 123* 12* 1* *123* *12* *1* *23* *2* *3* *]
    end
  end
end
