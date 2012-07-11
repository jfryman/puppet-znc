# Class: znc
#
# Description
#   This module is designed to install and manage ZNC, and IRC Bouncer
#
#   This module has been built and tested on RHEL systems.
#
# Parameters:
#   $auth_type: (plain|sasl). Will determine to use local auth or SASL auth.
#   $ssl: (true|false). To enable or disable SSL support. Will autogen a SSL certificate.
#   $port: port to run ZNC on.
#   $organizationName: Org Name for SSL Self Signed Cert
#   $localityName: City for SSL Self Signed Cert
#   $stateOrProvinceName: State or Province for SSL Self Signed Cert
#   $countryName: Country for SSL Self Signed Cert
#   $emailAddress: Admin email for SSL Self Signed Cert
#   $commonName: Common Name for SSL Self Signed Cert
#   
# Actions:
#   This module will install the ZNC and prep it to connect
#   to a local IRC server. Per-user settings can be reconfigured.
#
# Requires:
#  - An IRC server to connect to.
#  - Class[stdlib]. This is Puppet Labs standard library to include additional methods for use within Puppet. [https://github.com/puppetlabs/puppetlabs-stdlib]
# 
# Sample Usage:
#  class { 'znc': 
#    ssl                 => 'true', 
#    organizationName    => 'Fryman and Associates, Inc',
#    localityName        => 'Nashville',
#    stateOrProvinceName => 'TN',
#    countryName         => 'US',
#    emailAddress        => 'james@frymanandassociates.net',
#    commonName          => 'irc.frymanandassociates.net',
#  }
class znc(
  $auth_type           = $znc::params::zc_auth_type,
  $ssl                 = $znc::params::zc_ssl,
  $organizationName    = undef,
  $localityName        = undef,
  $stateOrProvinceName = undef,
  $countryName         = undef,
  $emailAddress        = undef,
  $commonName          = undef,
  $port                = $znc::params::zc_port
) inherits znc::params {
  include stdlib

  if $auth_type == 'sasl' { include saslauthd }

  # Make sure that all of the SSL parameters are filled out.
  if ($ssl == 'true') and 
    ($organizationName == undef or
     $localityName == undef or 
     $stateOrProvinceName == undef or 
     $countryName == undef or 
     $emailAddress == undef or 
     $commonName == undef) 
  {
    fail("Missing Parameters to generate an SSL Certificate")   
  }

  ### Begin Flow Logic ###
  anchor { 'znc::begin': }
  -> class { 'znc::package': }
  -> class { 'znc::config': 
       auth_type           => $auth_type,
       ssl                 => $ssl,
       organizationName    => $organizationName,
       localityName        => $localityName,
       stateOrProvinceName => $stateOrProvinceName,
       countryName         => $countryName,
       emailAddress        => $emailAddress,
       commonName          => $commonName,
       port                => $port,
     }
  ~> class { 'znc::service': }
  -> anchor { 'znc::end': }
}