# frozen_string_literal: true

class HtmlRenderer
  def render(results:)
    output = '<html><body><table>'
    results.each do |result|
      output += '<tr><td><table><tr><td>'
      output += result[:filename]
      output += '</td></tr><tr><td>'
      output += render_policy(result)
      output += render_role(result)
      output += '</td></tr></table></td></tr>'
    end
    output += '</table></body></html>'
    output
  end

  private

  def render_policy(result)
    output = ''
    if result[:file_results]['AWS::IAM::Policy'] != {}
      output += '<ul>'
      result[:file_results]['AWS::IAM::Policy'].each do |k, v|
        output += "<li>#{k}=#{v}</li>"
      end
      output += '</ul>'
    end
    output
  end

  def render_role(result)
    output = ''
    if result[:file_results]['AWS::IAM::Role'] != {}
      output += '<ul>'
      result[:file_results]['AWS::IAM::Role'].each do |role_id, policy_map|
        policy_map.each do |policy_name, metric|
          output += "<li>#{role_id}/#{policy_name}=#{metric}</li>"
        end
      end
      output += '</ul>'
    end
    output
  end
end
