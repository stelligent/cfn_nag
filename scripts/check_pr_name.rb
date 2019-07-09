# frozen_string_literal: true

require 'json'
require 'net/https'

ENV['CIRCLE_PULL_REQUEST'] = 'https://github.com/stelligent/cfn_nag/pull/243'
GITHUB_API_HOST = 'api.github.com'

def github_uri_path
  *_beginning, owner, repo, _pull, pr_number = ENV['CIRCLE_PULL_REQUEST'].split('/')
  "/repos/#{owner}/#{repo}/pulls/#{pr_number}"
end

def github_pr_title
  begin
    http = Net::HTTP.new(GITHUB_API_HOST, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Get.new(github_uri_path)
    request['Authorization'] = "token #{ENV['GITHUB_TOKEN']}"
    response = http.request(request)
  rescue StandardError => error
    abort "ERROR: Exception accessing github API: #{error.message}"
  end

  if response.code.to_i == 200
    JSON.parse(response.body)['title']
  else
    abort "ERROR: Github API response code #{response.code}: #{response.message}"
  end
end

pr_title = github_pr_title
unless pr_title.match(/#[0-9]+/)
  abort("ERROR: PR Title '#{pr_title}' needs to start with a issue number (example: #123 )")
end
