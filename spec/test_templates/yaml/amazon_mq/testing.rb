require 'cfn-model'
require 'cfn-nag'


def checknil(resource)
	if resource.nil?
		return true
	else 
		return false
	end
end

def check_name(resource, expected_name)
	if resource == expected_name
		return true
	end 
end 

cfn_model = CfnParser.new.parse IO.read('amazon_mq_broker_user_password_plain_text.yaml')

cfn_model.resources_by_type('AWS::AmazonMQ::Broker').each do |amzn_mq_broker|
	users = amzn_mq_broker.users
	users.each do |user|
		if checknil(user['Password']) || check_name(user['Password'], "NoEcho")
			puts "TRUE"
		else
			puts "FALSE"
		end 

	end
   # interrogate the iam_user
end



#violating_instances.map { |violating_instance| violating_instance.logical_resource_id }