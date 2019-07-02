# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/util/wildcard_patterns'

describe 'wildcard_patterns', :rule do
  context 'Passing "front" patterns option' do
    it 'returns patterns with * at front' do
      expect(wildcard_patterns('test', patterns: ['front'])).to eq %w[test *test *est *st *t *]
    end
  end

  context 'Passing "back" patterns option' do
    it 'returns patterns with * at back' do
      expect(wildcard_patterns('test', patterns: ['back'])).to eq %w[test test* tes* te* t* *]
    end
  end

  context 'Passing "both" pattern option' do
    it 'returns patterns with * at front and back' do
      expect(wildcard_patterns('test', patterns: ['both'])).to eq %w[test *test* *tes* *te* *t* *est* *es* *e* *st* *s* *t* *]
    end
  end

  context 'Passing "front" and "back" patterns options' do
    it 'returns patterns with * at front and * at back' do
      expect(wildcard_patterns('test', patterns: %w[front back])).to eq %w[test *test *est *st *t test* tes* te* t* *]
    end
  end

  context 'Passing no pattern option' do
    it 'returns all patterns( front, back, both)' do
      expect(wildcard_patterns('test')).to eq %w[test *test *est *st *t test* tes* te* t* *test* *tes* *te* *t* *est* *es* *e* *st* *s* *t* *]
    end
  end
end
