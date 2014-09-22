# Class: znc::service
#
# This module manages ZNC service management
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class znc::service {
  service { 'znc':
    ensure      => 'running',
    enable      => true,
    hasstatus   => true,
    hasrestart  => true,
  }

  exec { 'znc-reload':
    command     => '/etc/init.d/znc reload',
    refreshonly => true,
    logoutput   => on_failure,
  }
}
