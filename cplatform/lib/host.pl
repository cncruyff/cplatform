#!/usr/bin/perl
use warnings;
use strict;
use Sys::Hostname;
use Socket;
sub getHostIp{
	my $servername = hostname();
	my $packed_ip = gethostbyname($servername);
	my $ip_addr;
	if (defined $packed_ip){
		$ip_addr = inet_ntoa($packed_ip);
	}
	return $ip_addr;
}
sub getHostName{
	hostname();
}
1;
