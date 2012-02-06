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
  $auth_type           = '',
  $ssl                 = '',
  $organizationName    = '',
  $localityName        = '',
  $stateOrProvinceName = '',
  $countryName         = '',
  $emailAddress        = '',
  $commonName          = '',
  $port                = ''
) {
  include stdlib
  include znc::params
  if $auth_type == 'sasl' { include saslauthd }
  
  ### Begin Parameter Setting ###
  if $auth_type == '' { $REAL_auth_type = $znc::params::zc_auth_type }
  else { $REAL_auth_type = $auth_type }
  
  if $ssl == '' { $REAL_ssl = $znc::params::zc_ssl }
  else { $REAL_ssl = $ssl }
  
  if $port == '' { $REAL_port = $znc::params::zc_port }
  else { $REAL_port = $port }

  # Make sure that all of the SSL parameters are filled out.
  if ($ssl == 'true') and 
    ($organizationName == '' or
     $localityName == '' or 
     $stateOrProvinceName == '' or 
     $countryName == '' or 
     $emailAddress == '' or 
     $commonName == '') 
  {
    fail("Missing Parameters to generate an SSL Certificate")   
  }

  ### Begin Flow Logic ###
  anchor { 'znc::begin': }
  -> class { 'znc::package': }
  -> class { 'znc::config': 
       auth_type           => $REAL_auth_type,
       ssl                 => $REAL_ssl,
       organizationName    => $organizationName,
       localityName        => $localityName,
       stateOrProvinceName => $stateOrProvinceName,
       countryName         => $countryName,
       emailAddress        => $emailAddress,
       commonName          => $commonName,
       port                => $REAL_port,
     }
  ~> class { 'znc::service': }
  -> anchor { 'znc::end': }
}