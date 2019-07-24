# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/util/git.rb'
require 'git'

describe 'open_repo', :rule do
  context 'Location is a valid repo' do
    it 'returns a repo object' do
      Dir.mktmpdir do |dir|
        Git.init(dir)
        expect(open_repo(dir)).to(be_an(Git::Base))
      end
    end
  end
  context 'Location is not a valid repo' do
    it 'returns error' do
      Dir.mktmpdir do |dir|
        expect(open_repo(dir).to(raise_error))
      end
    end
  end
end
