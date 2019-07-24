# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/util/git.rb'
require 'git'

describe 'git', :rule do
  context 'open_repo when location is a valid repo' do
    it 'returns a repo object' do
      Dir.mktmpdir do |dir|
        Git.init(dir)
        expect(open_repo(dir)).to(be_an(Git::Base))
      end
    end
  end

  context 'open_repo when location is not a valid repo' do
    it 'raises error' do
      Dir.mktmpdir do |dir|
        expect { open_repo(dir) }.to raise_error(RuntimeError)
      end
    end
  end

  context 'repo_current_info for a repo without tags' do
    it 'returns new_version 0.0.1' do
      Dir.mktmpdir do |dir|
        Git.init(dir)
        expect(repo_current_info(dir)).to include('tag' => nil, 'version' => nil, 'major' => nil, 'minor' => nil, 'patch' => nil, 'new_version' => '0.0.1')
      end
    end
  end

  context 'repo_current_info for a repo with tag on latest commit' do
    it 'returns existing version' do
      Dir.mktmpdir do |dir|
        Git.init(dir)
        git = open_repo(dir)
        File.open("#{dir}/file1", 'w+') { |file| file.write('dummy data') }
        git.add("#{dir}/file1")
        git.commit('test commit')
        git.add_tag('v1.0.1', message: 'v1.0.1')
        expect(repo_current_info(dir)).to include('tag' => 'v1.0.1', 'version' => '1.0.1', 'major' => '1', 'minor' => '0', 'patch' => '1', 'new_version' => nil)
      end
    end
  end

  context 'repo_current_info for a repo with commits after last tag' do
    it 'returns existing version' do
      Dir.mktmpdir do |dir|
        Git.init(dir)
        git = open_repo(dir)
        File.open("#{dir}/file1", 'w+') { |file| file.write('dummy data') }
        git.add("#{dir}/file1")
        git.commit('test commit')
        git.add_tag('v1.0.1', message: 'v1.0.1')
        File.open("#{dir}/file2", 'w+') { |file| file.write('dummy data') }
        git.add("#{dir}/file2")
        git.commit('test commit2')
        expect(repo_current_info(dir)).to include('version' => '1.0.1', 'major' => '1', 'minor' => '0', 'patch' => '1', 'new_version' => '1.0.2')
      end
    end
  end
end
