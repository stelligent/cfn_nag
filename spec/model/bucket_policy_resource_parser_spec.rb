require 'spec_helper'
require 'model/bucket_policy_resource_parser'

describe BucketPolicyResourceParser do

  describe 'includes_wildcard?' do
    context 'single matching literal resource' do
      it 'returns true' do
        resource = 'arn:aws:s3:::fred/*'

        is_included = BucketPolicyResourceParser.new.includes_wildcard? resource

        expect(is_included).to be true
      end
    end

    context 'single matching FnJoin resource' do
      it 'returns true' do

        resource = {
          'Fn::Join' => [
            [
              '',
              [
                  'arn:aws:s3:::',
                  { 'Ref' => 'someGuysBucket' },
                  '/*'
              ]
            ]
          ]
        }

        is_included = BucketPolicyResourceParser.new.includes_wildcard? resource

        expect(is_included).to be true
      end
    end

    # context 'single non matching action' do
    #   it 'returns false' do
    #     action = 's3:DoSomething'
    #
    #     is_included = ActionParser.new.include? actual_action: action,
    #                                             action_to_look_for: 's3:fred'
    #
    #     expect(is_included).to be false
    #   end
    # end
    #
    # context 'array that includes a matching action' do
    #   it 'returns true' do
    #     action = %w(ec2:Do* s3:DoSomething s3:DontDoSomething)
    #
    #     is_included = ActionParser.new.include? actual_action: action,
    #                                             action_to_look_for: 's3:DoSomething'
    #
    #     expect(is_included).to be true
    #   end
    # end
    #
    # context 'single matching wild card action' do
    #   it 'returns true' do
    #     action ='s3:*'
    #
    #     is_included = ActionParser.new.include? actual_action: action,
    #                                             action_to_look_for: 's3:DoSomething'
    #
    #     expect(is_included).to be true
    #   end
    # end
    #
    # context 'array with matching wild card action' do
    #   it 'returns true' do
    #     action = %w(ec2:Do* s3:* s3:DontDoSomething)
    #
    #     is_included = ActionParser.new.include? actual_action: action,
    #                                             action_to_look_for: 's3:DoSomething'
    #
    #     expect(is_included).to be true
    #   end
    # end
    #
    # context 'array without matching wild card action' do
    #   it 'returns true' do
    #     action = %w(ec2:Do* s3:DoSo*thing s3:DontDoSomething)
    #
    #     is_included = ActionParser.new.include? actual_action: action,
    #                                             action_to_look_for: 's3:fred'
    #
    #     expect(is_included).to be false
    #   end
    # end
  end
end
