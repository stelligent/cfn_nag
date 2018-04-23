# Container for discovering templates
class TemplateDiscovery
  # input_json_path can be a directory, filename, or File
  def discover_templates(input_json_path)
    if ::File.directory? input_json_path
      return find_templates_in_directory(directory: input_json_path)
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
                                  cfn_extensions: %w[json yaml yml template])

    templates = []
    cfn_extensions.each do |cfn_extension|
      templates += Dir[File.join(directory, "**/*.#{cfn_extension}")]
    end
    templates
  end
end
