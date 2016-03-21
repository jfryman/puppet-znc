# Class: znc::config
#
# Description
#  This class is designed to configure the system to use ZNC after packages have
#  been deployed
#
# Parameters:
#   $auth_type: (plain|sasl). Will determine to use local auth or SASL auth.
#   $ssl: (true|false). To enable or disable SSL support. Will autogen a SSL certificate.
#   $port: port to run ZNC on.
#   $motd: Message of the day.
#   $ipv6: Enable/Disable IPv6 (enabled by default)
#   $organizationName: Org Name for SSL Self Signed Cert
#   $localityName: City for SSL Self Signed Cert
#   $stateOrProvinceName: State or Province for SSL Self Signed Cert
#   $countryName: Country for SSL Self Signed Cert
#   $emailAddress: Admin email for SSL Self Signed Cert
#   $commonName: Common Name for SSL Self Signed Cert
#
# Actions:
#  - Sets up ZNC Seed Configuration
#  - Sets up SSL (if configured)
#  - Sets up Regular Users from params [znc::user]
#  - Sets up Admin Users from params [znc::user, admin => true]
#
# Requires:
#  This module has no requirements
#
# Sample Usage:
#  This module should not be called directly.
class znc::config (
  $auth_type           = undef,
  $ssl                 = undef,
  $ssl_source          = undef,
  $organizationName    = undef,
  $localityName        = undef,
  $stateOrProvinceName = undef,
  $countryName         = undef,
  $emailAddress        = undef,
  $commonName          = undef,
  $global_modules      = undef,
  $motd                = undef,
  $ipv6                = undef,
  $systemd             = udnef,
  $port                = undef,) {
  File {
    owner => $::znc::params::zc_user,
    group => $::znc::params::zc_group,
    mode  => '0600',
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin' }

  case $::osfamily {
    'debian': {
      $nologin_shell = '/usr/sbin/nologin'
    }
    'redhat': {
      $nologin_shell = '/sbin/nologin'
    }
  }

  user { $::znc::params::zc_user:
    ensure  => present,
    uid     => $::znc::params::zc_uid,
    gid     => $::znc::params::zc_gid,
    shell   => $nologin_shell,
    comment => 'ZNC Service Account',
    system  => true,
  }

  group { $::znc::params::zc_group:
    ensure => present,
    gid    => $::znc::params::zc_gid,
  }

  file { $::znc::params::zc_config_dir: ensure => directory, }

  file { "${::znc::params::zc_config_dir}/configs":
    ensure  => directory,
    require => File[$::znc::params::zc_config_dir],
  }

  file { "${::znc::params::zc_config_dir}/configs/puppet_users":
    ensure  => directory,
    purge   => true,
    recurse => true,
    require => File["${::znc::params::zc_config_dir}/configs"],
  }

  file { "${::znc::params::zc_config_dir}/configs/znc.conf.header":
    ensure  => file,
    content => template('znc/configs/znc.conf.header.erb'),
    require => File["${::znc::params::zc_config_dir}/configs"],
  }

  file { "${::znc::params::zc_config_dir}/configs/znc.conf":
    ensure  => file,
    require => Exec['initialize-znc-config'],
  }

  file { '/etc/init.d/znc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("znc/etc/init.d/znc.${::znc::params::zc_suffix}.erb"),
  }
  if $systemd {
    include ::systemd
    file { '/lib/systemd/system/znc.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template('znc/systemd/znc.service.erb'),
    } ~> Exec['systemctl-daemon-reload']
  }

  # Bootstrap SSL
  if $ssl == true and !$ssl_source {
    file { "${::znc::params::zc_config_dir}/ssl":
      ensure => directory,
      mode   => '0600',
    }

    file { "${::znc::params::zc_config_dir}/bin": ensure => directory, }

    file { "${::znc::params::zc_config_dir}/bin/generate_znc_ssl":
      ensure  => file,
      mode    => '0755',
      content => template('znc/bin/generate_znc_ssl.erb'),
      require => [
        File["${::znc::params::zc_config_dir}/ssl"],
        File["${::znc::params::zc_config_dir}/bin"],
      ],
    }

    file { "${::znc::params::zc_config_dir}/znc.pem":
      ensure  => 'file',
      mode    => '0600',
      require => Exec['create-self-signed-znc-ssl'],
    }

    exec { 'create-self-signed-znc-ssl':
      command => "${::znc::params::zc_config_dir}/bin/generate_znc_ssl",
      creates => "${::znc::params::zc_config_dir}/znc.pem",
    }
  }

  if $ssl_source {
    file { "${::znc::params::zc_config_dir}/znc.pem":
      ensure  => file,
      mode    => '0600',
      content => $ssl_source,
    }
  }

  # Bootstrap config files
  exec { 'initialize-znc-config':
    command => "cat ${::znc::params::zc_config_dir}/configs/znc.conf.header > ${::znc::params::zc_config_dir}/configs/znc.conf",
    creates => "${::znc::params::zc_config_dir}/configs/znc.conf",
    require => File["${::znc::params::zc_config_dir}/configs/znc.conf.header"],
  }

}
