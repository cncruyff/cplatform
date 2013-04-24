#!/usr/bin/perl
use warnings;
use strict;
require "file.pl";


my $options = {logfile=>"/opt/cplatform/logwatch/1.log",key=>"error",threshold=>2,after=>2,alert=>\&action};
sub action{
	my $cont = shift;
	print "action is $cont\n";
}
checkfile($options);
