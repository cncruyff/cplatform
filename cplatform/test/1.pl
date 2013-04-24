#!/usr/bin/perl
use warnings;
use strict;
sub fork{
	print "i was forked!\n";
}
sub prefork{
	my $act = shift;
#	$act->();
	&$act;
}
prefork(\&fork);
