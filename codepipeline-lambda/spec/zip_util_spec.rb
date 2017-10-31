require 'spec_helper'
require 'json'
require 'zip_util'

describe ZipUtil, :zip do
  context 'zip doesnt exist' do
    it 'raises an error' do
      $lambdaInputMap = {}
      expect {
        _ = ZipUtil.read_files_from_zip '/tmp/somethingiwillneverfind', 'spec/test_templates/json/ec2_volume/*.json'
      }.to raise_error '/tmp/somethingiwillneverfind not found'
    end
  end

  context 'file within zip doesnt exist' do
    it 'raises an error' do
      $lambdaInputMap = {}
      expect {
        _ = ZipUtil.read_files_from_zip 'spec/test_templates/json_templates.zip', '/wrong/*.json'
      }.to raise_error /\/wrong\/\*\.json not found in .*/
    end
  end

  context 'three files in zip that match glob' do
    it 'returns string content of files' do
      contents = ZipUtil.read_files_from_zip 'spec/test_templates/json_templates.zip',
                                             'spec/test_templates/json/ec2_volume/*.json'

      expect(contents.size).to eq 3

      contents.each do |content|
        puts content[:name]
        # puts content[:contents]
      end
    end
  end
end