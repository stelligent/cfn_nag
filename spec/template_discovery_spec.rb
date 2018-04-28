require 'spec_helper'
require 'cfn-nag/template_discovery'
require 'tempfile'
require 'fileutils'
require 'set'

describe TemplateDiscovery do
  before(:each) do
    @template_discovery = TemplateDiscovery.new
  end

  describe '#discover_templates' do
    context 'illegitimate path' do
      it 'raises an error' do
        expect do
          @template_discovery.discover_templates input_json_path: '/an/impossible/path/to/find'
        end.to raise_error '/an/impossible/path/to/find is not a proper path'
      end
    end

    context 'input path is file' do
      it 'returns array with filename' do
        Tempfile.open('/foo') do |tempfile|
          actual_templates = @template_discovery.discover_templates(
            input_json_path: tempfile.path
          )
          expected_templates = [tempfile.path]
          expect(actual_templates).to eq expected_templates
        end
      end
    end

    context 'input path is directory with json, template, yaml, yml' do
      it 'returns array with matching files' do
        begin
          temp_directory = "/tmp/testing#{Time.now.to_i}"
          FileUtils.mkdir_p "#{temp_directory}/secondlevel"
          File.open("#{temp_directory}/secondlevel/foo1.yml", 'w+') do |f|
            f.write 'foo1'
          end
          File.open("#{temp_directory}/secondlevel/foo2.yaml", 'w+') do |f|
            f.write 'foo2'
          end
          File.open("#{temp_directory}/foo3.template", 'w+') do |f|
            f.write 'foo3'
          end
          File.open("#{temp_directory}/foo4.json", 'w+') { |f| f.write 'foo4' }
          File.open("#{temp_directory}/foo5", 'w+') { |f| f.write 'foo5' }

          actual_templates = @template_discovery.discover_templates(
            input_json_path: temp_directory
          )

          expected_templates = %W[
            #{temp_directory}/secondlevel/foo1.yml
            #{temp_directory}/secondlevel/foo2.yaml
            #{temp_directory}/foo3.template
            #{temp_directory}/foo4.json
          ]
          expect(Set.new(actual_templates)).to eq Set.new(expected_templates)
        ensure
          FileUtils.rm_rf temp_directory
        end
      end
    end
  end
end
