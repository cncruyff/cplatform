#!/usr/bin/perl
use warnings;
use strict;


sub checkfile{
my $options = shift;
my ($logfile,$key,$threshold,$after,$alert) = ($options->{'logfile'},$options->{'key'},$options->{'threshold'},$options->{'after'},$options->{'alert'});
my $errcnt = 0;
my @reserver;
open(LOG,"<$logfile") || die "can't open log file $logfile $!";
my $inode = (stat(LOG))[1];
my $tmp = "tmp/$inode.tmp";
my $curpos;
if(-e $tmp){
        open(TMP,"<$tmp") or die "can't open file $tmp !";
        $curpos = <TMP>;
        chomp $curpos;
        close TMP;
}
$curpos = $curpos || 0;
seek(LOG,$curpos,0);
while(my $line=<LOG>){
        #chomp $line;
        if($line =~ /$key/){
                $errcnt++;
		$curpos = tell(LOG);
                $reserver[$errcnt%$threshold] = $curpos - length($line);
        #        scalar(@$reserver) > $threshold and shift @$reserver;
        }
}
$curpos = tell(LOG);
if($errcnt >= $threshold){
        open(TMP,">$tmp") or die "can't open file $tmp !";
        print TMP $curpos;
        close TMP;
        print "exception over $threshold times\n";
	my $cont;
	foreach(@reserver){
		if(defined){
			$cont .= getafter(*LOG,$_,$after);
		}
	}
	$options->{error} = $cont;
	$options->{'alert'}->($cont);

}
close LOG;
}
sub getafter{
	my($fh,$pos,$after) = @_;
	seek($fh,$pos,0);
	my $cont = <$fh>;
	print "error  $cont";
	while(defined(my $line=<$fh>) and $after>0){
		$cont .= "\t".$line;
		print "after $line";
		$after--;	
	}
	$cont;
}
1;
