# Class: znc::params
#
# Description
#   This class is designed to carry default parameters for
#   Class: znc.
#
# Parameters:
#   $zc_suffix   - The suffix for the init.d script for ZNC located in files/etc/init.d/
#   $zc_packages - List of packages required to install ZNC
#   $zc_auth_type - Default auth type if not configured
#   $zc_ssl - Default SSL status if not configured
#   $zc_port - Default port if not configured
#   $znc_admins - list of users that have admin priveleges in ZNC
#   $znc_users - list of znc users.
#
# Actions:
#   This module does not perform any actions.
#
# Requires:
#   This module has no requirements.
#
# Sample Usage:
#   This method should not be called directly.
class znc::params {
  $zc_packages = [ 'znc', 'znc-tcl', 'znc-perl' ]

  $zc_user       = 'znc'
  $zc_group      = 'znc'
  $zc_uid        = '400'
  $zc_gid        = '400'
  $zc_config_dir = '/etc/znc'
  $zc_auth_type  = 'plain'
  $zc_ssl        = true
  $zc_port       = '7777'
}
