# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule < BaseRule
  def rule_text
    'EMR SecurityConfiguration should enable and properly configure encryption at rest and in transit.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W61'
  end

  def audit_impl(cfn_model)
    violating_emr_sec_configs = cfn_model.resources_by_type('AWS::EMR::SecurityConfiguration').select do |sec_config|
      bad_security_config?(sec_config)
    end

    violating_emr_sec_configs.map(&:logical_resource_id)
  end

  private

  def bad_security_config?(security_config_object)
    # Poorly formatted SecurityConfiguration
    return true unless security_config_object.securityConfiguration['EncryptionConfiguration']

    encryption_config = security_config_object.securityConfiguration['EncryptionConfiguration']

    # Either encryption type disabled
    return true unless encryption_config['EnableAtRestEncryption'] && encryption_config['EnableInTransitEncryption']

    bad_at_rest_encryption?(encryption_config) || bad_in_transit_encryption?(encryption_config)
  end

  def bad_at_rest_encryption?(config)
    # Missing AtRestEncryptionConfiguration
    return true unless config.key?('AtRestEncryptionConfiguration')

    # AtRest encryptions misconfigured
    return true unless \
      (config['AtRestEncryptionConfiguration'].key?('LocalDiskEncryptionConfiguration') &&
       config['AtRestEncryptionConfiguration']['LocalDiskEncryptionConfiguration'].key?('EncryptionKeyProviderType')) ||
      (config['AtRestEncryptionConfiguration'].key?('S3EncryptionConfiguration') &&
       config['AtRestEncryptionConfiguration']['S3EncryptionConfiguration'].key?('EncryptionMode'))

    false
  end

  def bad_in_transit_encryption?(config)
    # Missing InTransitEncryptionConfiguration
    return true unless config.key?('InTransitEncryptionConfiguration')

    # InTransit encryptions misconfigured
    return true unless \
      config['InTransitEncryptionConfiguration'].key?('TLSCertificateConfiguration') &&
      config['InTransitEncryptionConfiguration']['TLSCertificateConfiguration'].key?('CertificateProviderType')

    false
  end
end
