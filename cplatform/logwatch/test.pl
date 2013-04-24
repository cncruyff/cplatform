#!/usr/bin/perl
use warnings;
use strict;
use POSIX qw(strftime);
use Cwd;
require "/opt/cplatform/lib/mail.pl";


my $conf = "monitor.conf";
parse();
sub parse{
        open(CNF,"$conf") || die "can't open file $conf $!";
        while(my $line = <CNF>){
                chomp $line;
                my @items = split(",",$line);
                my ($logs,$k,$thr) = (@items);
                $logs =~ s/<(.*?)>/strftime("$1", localtime)/ge;
		foreach my $log	(glob($logs)){
			print "$log,$k,$thr\n";	
		}	
        }
	close CNF;
}

