require 'netaddr'

module IpAddr
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
    (NetAddr::CIDRv6.create(normalized_cidr_ip6) ==
     NetAddr::CIDRv6.create('::/0'))
  end

  def ip4_cidr_range?(ingress)
    ingress.cidrIp.is_a?(String) && !ingress.cidrIp.end_with?('/32')
  end

  def ip6_cidr_range?(ingress)
    normalized_cidr_ip6 = normalize_cidr_ip6(ingress)
    return false if normalized_cidr_ip6.nil?

    # only care about literals.  if a Hash/Ref not going to chase it down
    # given likely a Parameter with external val
    !NetAddr::CIDRv6.create(normalized_cidr_ip6).to_s.end_with?('/128')
  end

  ##
  # If it's a string, just pass through
  # If it's a symbol - probably because the YAML.load call treats an unquoted
  # ::/0 as a the symbol :':/0'
  # Otherwise it's probably a Ref or whatever and we aren't going to do
  # anything with it
  #
  def normalize_cidr_ip6(ingress)
    if ingress.cidrIpv6.is_a?(Symbol)
      ":#{ingress.cidrIpv6}"
    elsif ingress.cidrIpv6.is_a?(String)
      ingress.cidrIpv6
    end
  end
end
