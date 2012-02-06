# Class: znc::package
#
# Description
#   This class is designed to install the packages for ZNC
#   Packages are controlled via the Params class on a per-OS basis.
#
# Parameters:
#   This class takes no parameters
#
# Actions:
#   This class installs ZNC packages.
#
# Requires:
#   This module has no requirements.   
#
# Sample Usage:
#   This method should not be called directly.
class znc::package {
  package { $znc::params::zc_packages: 
    ensure => present
  }
}