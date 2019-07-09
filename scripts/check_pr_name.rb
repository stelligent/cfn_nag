# frozen_string_literal: true

require 'json'
require 'net/http'

# ENV['CIRCLE_PULL_REQUEST'] = 'https://github.com/stelligent/cfn_nag/pull/243'
GITHUB_API_HOST = 'api.github.com'
REQUEST_PATH = "/repos/#{ENV['CIRCLE_PROJECT_USERNAME']}"\
               "/#{ENV['CIRCLE_PROJECT_REPONAME']}"\
               "/pulls/#{ENV['CIRCLE_PR_NUMBER']}"

def http_connection
  http = Net::HTTP.new(GITHUB_API_HOST, 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  http
end

def github_pr_title
  begin
    request = Net::HTTP::Get.new(REQUEST_PATH)
    request['Authorization'] = "token #{ENV['GITHUB_API_TOKEN']}"
    response = http_connection.request(request)
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
