# ZNC Module

James Fryman <james@frymanet.com>

This module manages ZNC from within Puppet.

# Quick Start

Install and bootstrap a ZNC instance

# Requirements

Puppet Labs Standard Library
- http://github.com/puppetlabs/puppetlabs-stdlib

<pre>
  class { 'znc':
    ssl                 => 'true',
    organizationName    => 'Fryman and Associates, Inc',
    localityName        => 'Nashville',
    stateOrProvinceName => 'TN',
    countryName         => 'US',
    emailAddress        => 'james@frymanandassociates.net',
    commonName          => 'irc.frymanandassociates.net',
  }
</pre>
