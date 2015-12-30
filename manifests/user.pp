# Define: znc::user
#
# Description:
#  This custom definition will create a stub file to allow ZNC users
#  to be added to the running config while not overwriting
#  any settings changed via the web interface.
#
# Parameters:
#  $admin: (true|false) describes whether a user is an admin user or not.
#
# Actions:
#   Installs a stub file with a default set of parameters in the users directory
#   This is a managed file-fragment directory that is also used to clean users
#   from the config file if necessary as well
#
# Requires:
#
# Sample Usage:
#   znc::user { 'jfryman': }
#
# This class file is not called directly
define znc::user (
  $ensure          = 'present',
  $realname        = undef,
  $admin           = false,
  $buffer          = 500,
  $keepbuffer      = true,
  $server          = 'irc.freenode.net',
  $port            = 6667,
  $ssl             = false,
  $quitmsg         = 'quit',
  $pass            = '',
  $channels        = undef,
  $network         = undef,) {
  if ! defined(Class['znc']) {
    fail('You must include znc base class before using any user defined resources')
  }
  include znc::params

  File {
    owner => $::znc::params::zc_user,
    group => $::znc::params::zc_group,
    mode  => '0600',
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin', }

  if $ensure == 'present' {
    file { "${::znc::params::zc_config_dir}/configs/puppet_users/${name}":
      ensure  => file,
      content => template('znc/configs/znc.conf.seed.erb'),
      before  => Exec["add-znc-user-${name}"],
    }

    exec { "add-znc-user-${name}":
      command => "cat ${::znc::params::zc_config_dir}/configs/puppet_users/${name} >> ${::znc::params::zc_config_dir}/configs/znc.conf",
      unless  => "grep -F \"<User ${name}>\" ${::znc::params::zc_config_dir}/configs/znc.conf",
      require => Exec['initialize-znc-config'],
      notify  => Exec['znc-reload'],
    }
  }

  if $ensure == 'absent' {

    file { "${::znc::params::zc_config_dir}/users/${name}":
      ensure => absent,
      force  => true,
    }

    file { "${::znc::params::zc_config_dir}/configs/puppet_users/${name}":
      ensure => absent,
      before => Exec["remove-znc-user-${name}"],
    }

    exec { "remove-znc-user-${name}":
      command => "sed -i \"/<User ${name}>/,/<\\/User>/ d\" ${::znc::params::zc_config_dir}/configs/znc.conf",
      onlyif  => "grep -Fc \"<User ${name}>\" ${::znc::params::zc_config_dir}/configs/znc.conf",
      notify  => Exec['znc-reload'],
    }
  }

}
