# frozen_string_literal: true

require 'httparty'

# ENV['CIRCLE_PULL_REQUEST'] = 'https://github.com/stelligent/cfn_nag/pull/243'
# GITHUB_API_URL = 'https://api.github.com'

def get_pr_title
  *beginning, owner, repo, _pull, pr_number = ENV['CIRCLE_PULL_REQUEST'].split('/')
  pr_url = "#{GITHUB_API_URL}/repos/#{owner}/#{repo}/pulls/#{pr_number}"
  headers = { 'Authorization' => "token #{ENV['GITHUB_TOKEN']}", 'User-Agent' => 'Httparty' }

  begin
    response = HTTParty.get(pr_url, headers: headers)
  rescue Exception => error
    abort "ERROR: Exception accessing github API: #{error.message}"
  end

  if response.code.to_i == 200
    response['title']
  else
    abort "ERROR: Github API response code #{response.code}: #{response.message}"
  end
end

pr_title = get_pr_title
unless pr_title.match(/#[0-9]+/)
  abort("ERROR: PR Title '#{pr_title}' needs to start with a issue number (example: #123 )")
end
