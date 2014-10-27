# Class: znc
#
# Description
#   This module is designed to install and manage ZNC, and IRC Bouncer
#
#   This module has been built and tested on RHEL systems.
#   This module has been tested on Ubuntu 14.04 LTS (with znc version 1.4)
#
# Parameters:
#   $auth_type: (plain|sasl). Will determine to use local auth or SASL auth.
#   $ssl: (true|false). Will autogen a SSL certificate.
#   $ssl_source: puppet:///path/to/server.pem
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
#  - Class[stdlib]. https://forge.puppetlabs.com/puppetlabs/stdlib
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
#    motd                => 'Message of the server'
#    global_modules      => ['module_name1','module_name2']
#  }
#  NOTE: In case of global_modules, please be sure, that the list
#   of provided modules are available for global scope [http://wiki.znc.in/Modules]

class znc(
  $auth_type           = $::znc::params::zc_auth_type,
  $ssl_source          = undef,
  $ssl                 = $::znc::params::zc_ssl,
  $organizationName    = undef,
  $localityName        = undef,
  $stateOrProvinceName = undef,
  $countryName         = undef,
  $emailAddress        = undef,
  $commonName          = undef,
  $motd                = undef,
  $global_modules      = undef,
  $ipv6                = $::znc::params::zc_ipv6,
  $port                = $::znc::params::zc_port,

  $znc_admin_user      = $::znc::params::znc_admin_user,
  $znc_admin_pass      = $::znc::params::znc_admin_pass,
  $znc_admin_channels  = $::znc::params::znc_admin_channels

) inherits ::znc::params {
  include stdlib

  ### Begin Flow Logic ###
  anchor { 'znc::begin': }
  -> class { '::znc::package': }
  -> class { '::znc::config':
      auth_type           => $auth_type,
      ssl                 => $ssl,
      ssl_source          => $ssl_source,
      organizationName    => $organizationName,
      localityName        => $localityName,
      stateOrProvinceName => $stateOrProvinceName,
      countryName         => $countryName,
      emailAddress        => $emailAddress,
      commonName          => $commonName,
      global_modules      => $global_modules,
      motd                => $motd,
      ipv6                => $ipv6,
      port                => $port,
    }
      # we need to define at least one user in order to start service
  -> ::znc::user { $znc_admin_user :
    realname => 'Default Admin User',
    admin    => true,
    pass     => $znc_admin_pass,
    channels => $znc_admin_channels,
  }
  ~> class { '::znc::service': }
  -> anchor { 'znc::end': }
}
