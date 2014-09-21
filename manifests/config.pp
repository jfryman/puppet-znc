# Class: znc::config
#
# Description
#  This class is designed to configure the system to use ZNC after packages have
#  been deployed
#
# Parameters:
#   $auth_type: (plain|sasl). Will determine to use local auth or SASL auth.
#   $ssl: (true|false). To enable or disable SSL support. Will autogen a SSL
#   certificate.
#   $port: port to run ZNC on.
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
  $port                = 7777,) {
  File {
    owner => $znc::params::zc_user,
    group => $znc::params::zc_group,
    mode  => '0600',
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin' }

  user { $znc::params::zc_user:
    ensure     => present,
    uid        => $znc::params::zc_uid,
    gid        => $znc::params::zc_gid,
    shell      => '/bin/bash',
    comment    => 'ZNC Service Account',
    managehome => true,
  }

  group { $znc::params::zc_group:
    ensure => present,
    gid    => $znc::params::zc_gid,
  }

  file { $znc::params::zc_config_dir: ensure => directory, }

  file { "${znc::params::zc_config_dir}/configs": ensure => directory, }

  file { "${znc::params::zc_config_dir}/configs/puppet_users":
    ensure  => directory,
    purge   => true,
    recurse => true,
    notify  => Exec['remove-unmanaged-users'],
  }

  file { "${znc::params::zc_config_dir}/configs/znc.conf.header":
    ensure  => file,
    content => template('znc/configs/znc.conf.header.erb'),
  }

  file { "${znc::params::zc_config_dir}/configs/znc.conf":
    ensure  => file,
    require => Exec['initialize-znc-config'],
  }

  file { '/etc/init.d/znc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('znc/etc/init.d/znc.erb'),
  }

  file { "${znc::params::zc_config_dir}/bin/clean_users":
    ensure  => file,
    owner   => $znc::params::zc_uid,
    group   => $znc::params::zc_gid,
    mode    => '0754',
    content => template('znc/bin/clean_znc_users.erb'),
  }

  # Bootstrap SSL
  if $ssl == true and !$ssl_source {
    file { "${znc::params::zc_config_dir}/ssl":
      ensure => directory,
      mode   => '0600',
    }

    file { "${znc::params::zc_config_dir}/bin": ensure => directory, }

    file { "${znc::params::zc_config_dir}/bin/generate_znc_ssl":
      ensure  => file,
      mode    => '0755',
      content => template('znc/bin/generate_znc_ssl.erb'),
      require => File["${znc::params::zc_config_dir}/ssl"],
    }

    file { "${znc::params::zc_config_dir}/znc.pem":
      ensure  => 'file',
      mode    => '0600',
      require => Exec['create-self-signed-znc-ssl'],
    }

    exec { 'create-self-signed-znc-ssl':
      command => "${znc::params::zc_config_dir}/bin/generate_znc_ssl",
      creates => "${znc::params::zc_config_dir}/znc.pem",
    }
  }

  if $ssl_source {
    file { "${znc::params::zc_config_dir}/znc.pem":
      ensure => file,
      mode   => '0600',
      source => $ssl_source,
    }
  }

  # Bootstrap config files
  exec { 'initialize-znc-config':
    command => "cat ${znc::params::zc_config_dir}/configs/znc.conf.header > ${znc::params::zc_config_dir}/configs/znc.conf",
    creates => "${znc::params::zc_config_dir}/configs/znc.conf",
    require => File["${znc::params::zc_config_dir}/configs/znc.conf.header"],
  }

  exec { 'remove-unmanaged-users':
    command     => "${znc::params::zc_config_dir}/bin/clean_users",
    refreshonly => true,
    require     => File["${znc::params::zc_config_dir}/bin/clean_users"],
  }
}
