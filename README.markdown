# ZNC Module

James Fryman <james@frymanet.com>

This module manages ZNC (1.4) from within Puppet

# Quick Start

Install and bootstrap a ZNC instance

Simple Usage:
<pre>
  class { '::znc' :
    ssl                 => 'true',
    organizationName    => 'Fryman and Associates, Inc',
    localityName        => 'Nashville',
    stateOrProvinceName => 'TN',
    countryName         => 'US',
    emailAddress        => 'james@frymanandassociates.net',
    commonName          => 'irc.frymanandassociates.net',
    motd                => 'Message of the day'
    global_modules      => ['module_name1','module_name2'],
    ipv6                => false,
  }

  # create some user
  ::znc::user { 'USERNAME' :
    realname  => 'User Test',
    admin     => true,
    pass      => '123',
    channels  => ['#channel1','#channel2'],
  }
</pre>

# Requirements

Puppet Labs Standard Library
- http://github.com/puppetlabs/puppetlabs-stdlib
- znc (1.4) (new version can be used from https://launchpad.net/~teward/+archive/ubuntu/znc)
