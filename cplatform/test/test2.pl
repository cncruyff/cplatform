#!/usr/bin/perl
use warnings;
use strict;
sub test{
	my $arg = shift;
	print "the arg is :$arg!";
}
my $test_ref = \&test;
&$test_ref('hello');
