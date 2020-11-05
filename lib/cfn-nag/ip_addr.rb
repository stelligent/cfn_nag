# frozen_string_literal: true

require 'netaddr'

module IpAddr
  def ip4_localhost?(egress)
    egress.cidrIp.is_a?(String) && egress.cidrIp == '127.0.0.1/32'
  end

  def ip6_localhost?(egress)
    egress.cidrIpv6.to_s == '::1/128' || egress.cidrIpv6.to_s == ':1/128'
  end

  def ip4_open?(ingress)
    # only care about literals.  if a Hash/Ref not going to chase it down
    # given likely a Parameter with external val
    ingress.cidrIp.is_a?(String) && ingress.cidrIp == '0.0.0.0/0'
  end

  def ip6_open?(ingress)
    normalized_cidr_ip6 = normalize_cidr_ip6(ingress)
    return false if normalized_cidr_ip6.nil?

    # only care about literals.  if a Hash/Ref not going to chase it down
    # given likely a Parameter with external val
    NetAddr::IPv6Net.parse(normalized_cidr_ip6).cmp(NetAddr::IPv6Net.parse('::/0')).zero?
  end

  def ip4_cidr_range?(ingress)
    ingress.cidrIp.is_a?(String) && !ingress.cidrIp.end_with?('/32')
  end

  def ip6_cidr_range?(ingress)
    normalized_cidr_ip6 = normalize_cidr_ip6(ingress)
    return false if normalized_cidr_ip6.nil?

    # only care about literals.  if a Hash/Ref not going to chase it down
    # given likely a Parameter with external val
    !NetAddr::IPv6Net.parse(normalized_cidr_ip6).to_s.end_with?('/128')
  end

  ##
  # If it's a string, just pass through
  # If it's a symbol - probably because the YAML.load call treats an unquoted
  # ::/0 as a the symbol :':/0'
  # Otherwise it's probably a Ref or whatever and we aren't going to do
  # anything with it
  #
  def normalize_cidr_ip6(ingress)
    case ingress.cidrIpv6
    when Symbol
      ":#{ingress.cidrIpv6}"
    when String
      ingress.cidrIpv6
    end
  end
end
