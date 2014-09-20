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
define znc::user(
  $ensure = 'present',
  $realname = '',
  $admin  = false,
  $buffer = 500,
  $keepbuffer = true,
  $server = 'irc.freenode.net',
  $port = 6667,
  $ssl = false,
  $quitmsg = 'quit',
  $pass = '',
  $default_channel = '#persTest',
  $channels = ['#persTest1','#persTest2'],
) {
  include znc::params

  File {
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $ensure == 'present' {
    file { "${znc::params::zc_config_dir}/configs/users/${name}":
      ensure  => file,
      content => template('znc/configs/znc.conf.seed.erb'),
      before  => Exec["add-znc-user-${name}"],
    }
    exec { "add-znc-user-${name}":
      command => "cat ${znc::params::zc_config_dir}/configs/users/${name} >> ${znc::params::zc_config_dir}/configs/znc.conf",
      unless  => "grep ${name} ${znc::params::zc_config_dir}/configs/znc.conf",
      require => Exec['initialize-znc-config'],
      notify  => Service['znc'],
    }
  }
}
