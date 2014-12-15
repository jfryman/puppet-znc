# ZNC Module

James Fryman <james@frymanet.com>

This module manages ZNC (1.4) from within Puppet

# Quick Start

Install and bootstrap a ZNC instance

> For security reasons, admin user is not allowed to connect to any IRC servers

Simple Usage:
<pre>
  class { '::znc' :
    ssl                 => true,
    organizationName    => 'Fryman and Associates, Inc',
    localityName        => 'Nashville',
    stateOrProvinceName => 'TN',
    countryName         => 'US',
    emailAddress        => 'james@frymanandassociates.net',
    commonName          => 'irc.frymanandassociates.net',
    motd                => 'Message of the day'
    global_modules      => ['webadmin','adminlog'],
    ipv6                => false,

    znc_admin_user      => 'adminZ',
    znc_admin_pass      => 'somep4ss',
  }

  # create some user
  ::znc::user { 'USERNAME' :
    realname  => 'User Test',
    admin     => false,
    pass      => '123',
    channels  => ['#channel1','#channel2'],
  }
</pre>

# Requirements

Puppet Labs Standard Library
- http://github.com/puppetlabs/puppetlabs-stdlib
- znc (1.4) (new version can be used from https://launchpad.net/~teward/+archive/ubuntu/znc)
