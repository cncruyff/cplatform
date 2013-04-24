#!/usr/bin/perl
use warnings;
use strict;
require "/opt/cplatform/lib/host.pl";

my $name = getHostName();
my $ip = getHostIp();
print $name,"\n";
print $ip,"\n";
