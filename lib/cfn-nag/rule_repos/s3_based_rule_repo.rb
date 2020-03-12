# frozen_string_literal: true

require 'aws-sdk-s3'
require 'lightly'
require 'json'
require 'logging'
require_relative '../rule_registry'
require_relative '../rule_repo_exception'

class Object
  ##
  # This is meta-magic evil.  eval apparently has lexical scope so... opening up Object to
  # evaluate ruby code that contains top-level Class definitions
  #
  # Without this, the class ends up "under" the scope of the class which in this case would be
  # S3BucketBasedRuleRepo
  #
  # rubocop:disable Security/Eval
  def eval_code_in_object_scope(code)
    eval code
  end
  # rubocop:enable Security/Eval
end

class S3BucketBasedRuleRepo
  attr_reader :prefix, :s3_bucket_name, :index_life_time, :aws_profile

  def initialize(s3_bucket_name:, prefix:, index_lifetime: '1h', aws_profile: nil)
    @s3_bucket_name = s3_bucket_name
    @prefix = remove_leading_slash(prefix)
    @index_cache = Lightly.new(
      dir: cache_path('cfn_nag_s3_index_cache', s3_bucket_name),
      life: index_lifetime,
      hash: true
    )

    # except in dev mode, rules are immutable so once we have it don't worry about it changing
    @rule_cache = Lightly.new(
      dir: cache_path('cfn_nag_s3_rule_cache', s3_bucket_name),
      life: '1000d',
      hash: true
    )
    @aws_profile = aws_profile
    @s3_resource = nil
  end

  def discover_rules
    Logging.logger['log'].debug "S3BucketBasedRuleRepo.discover_rules in #{@s3_bucket_name}, #{@prefix}"

    rule_registry = RuleRegistry.new

    index = index(@s3_bucket_name, @prefix)
    Logging.logger['log'].debug "index: #{index}"

    index.each do |rule_object_key|
      rule_code = @rule_cache.get(rule_object_key) do
        cache_miss(rule_object_key)
      end

      rule_class_name = select_class_name_from_object_key(rule_object_key)

      eval_code_in_object_scope rule_code

      rule_registry.definition(Object.const_get(rule_class_name))
    end

    rule_registry
  end

  def nuke_cache
    cached_dirs = [
      cache_path('cfn_nag_s3_index_cache', @s3_bucket_name),
      cache_path('cfn_nag_s3_rule_cache', @s3_bucket_name)
    ]
    FileUtils.rm_rf(cached_dirs)
  end

  private

  def cache_miss(key)
    Logging.logger['log'].debug "cache_miss: #{key}"

    rule_code_record = s3_object_content(@s3_bucket_name, key)
    rule_code_record.body.read
  end

  def cache_path(cache_name, s3_bucket_name)
    "/tmp/#{cache_name}/#{s3_bucket_name}"
  end

  def s3_resource
    return @s3_resource unless @s3_resource.nil?

    @s3_resource = @aws_profile ? Aws::S3::Resource.new(profile: @aws_profile) : Aws::S3::Resource.new
  end

  def select_class_name_from_object_key(key)
    key.split('/')[-1].gsub('.rb', '')
  end

  def index(s3_bucket_name, prefix)
    index_json_str = @index_cache.get('index_cfn_nag') do
      discover_rule_s3_objects(s3_bucket_name, prefix).to_json
    end
    JSON.parse(index_json_str)
  end

  def s3_object(s3_bucket_name, key)
    rule_bucket = s3_resource.bucket(s3_bucket_name)
    rule_bucket.object key
  end

  def s3_object_content(s3_bucket_name, key)
    s3_object(s3_bucket_name, key).get
  end

  def discover_rule_s3_objects(s3_bucket_name, prefix)
    rule_bucket = s3_resource.bucket(s3_bucket_name)
    objects = rule_bucket.objects(prefix: prefix)
    rule_objects = objects.select do |object|
      object.key.match(/.*Rule\.rb/)
    end
    Logging.logger['log'].debug "Found rule objects: #{rule_objects}"
    rule_objects.map(&:key)
  rescue Aws::S3::Errors::NoSuchBucket
    raise RuleRepoException.new(msg: "Rule bucket not found: #{s3_bucket_name}")
  end

  def remove_leading_slash(s3_key)
    s3_key.start_with?('/') ? s3_key[1..-1] : s3_key
  end
end
