# frozen_string_literal: true

# Container for discovering templates
class TemplateDiscovery
  # input_json_path can be a directory, filename, or File
  def discover_templates(input_json_path:,
                         template_pattern: '..*\.json|..*\.yaml|..*\.yml|..*\.template')
    if ::File.directory? input_json_path
      return find_templates_in_directory(directory: input_json_path,
                                         template_pattern: template_pattern)
    end
    return [render_path(input_json_path)] if ::File.file? input_json_path

    raise "#{input_json_path} is not a proper path"
  end

  private

  def render_path(path)
    return path.path if path.is_a? File

    path
  end

  def find_templates_in_directory(directory:,
                                  template_pattern:)

    templates = []
    Dir[File.join(directory, '**/**')].each do |file_name|
      if file_name.match?(template_pattern)
        templates << file_name
      end
    end
    templates
  end
end
