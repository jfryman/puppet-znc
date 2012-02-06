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
  $admin = 'false'
) {
  File {
    owner => 'root',
    group => 'root',
    mode  => '0600',
  }
  Exec { 
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }
  
  file { "/etc/znc/configs/users/${name}":
    ensure  => file,
    content => template('znc/etc/znc/configs/znc.conf.seed.erb'),
    before  => Exec["add-znc-user-${name}"],
  } 
  exec { "add-znc-user-${name}":
    command => "cat /etc/znc/configs/users/${name} >> /etc/znc/configs/znc.conf",
    unless  => "grep ${name} /etc/znc/configs/znc.conf",
    require => Exec['initialize-znc-config'],
    notify  => Service['znc'],
  }
}