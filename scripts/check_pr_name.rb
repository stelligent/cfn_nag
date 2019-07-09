# frozen_string_literal: true

require 'httparty'

# ENV['CIRCLE_PULL_REQUEST'] = 'https://github.com/stelligent/cfn_nag/pull/243'
# GITHUB_API_URL = 'https://api.github.com'

def github_url
  *_beginning, owner, repo, _pull, pr_number = ENV['CIRCLE_PULL_REQUEST'].split('/')
  "#{GITHUB_API_URL}/repos/#{owner}/#{repo}/pulls/#{pr_number}"

def github_pr_title
  headers = { 'Authorization' => "token #{ENV['GITHUB_TOKEN']}", 'User-Agent' => 'Httparty' }

  begin
    response = HTTParty.get(github_url, headers: headers)
  rescue StandardError => error
    abort "ERROR: Exception accessing github API: #{error.message}"
  end

  if response.code.to_i == 200
    response['title']
  else
    abort "ERROR: Github API response code #{response.code}: #{response.message}"
  end
end

pr_title = github_pr_title
unless title.match(/#[0-9]+/)
  abort("ERROR: PR Title '#{title}' needs to start with a issue number (example: #123 )")
end
