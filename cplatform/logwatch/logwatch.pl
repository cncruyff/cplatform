#!/usr/bin/perl
use warnings;
use strict;
use POSIX qw(strftime);
use Cwd;
use Sys::Hostname;
require "/opt/cplatform/lib/mail.pl";


my $server_ip = hostname();
my $log = "run.log";
my $mailto = 'wenqi@c-platform.com,xuxy@c-platform.com,sunyx@c-platform.com';
my $conf = "monitor.conf";

#my $logfile = "/usr/local/program/shlm/tomcat-others/logs/catalina.out";
#my $key = "Exception";
#my $threshold = 10;

#checkfile($logfile,$key,$threshold);
parse();


sub parse{
	open(CNF,"$conf") || die "can't open file $conf $!";
	while(my $line = <CNF>){
		chomp $line;
		my @items = split(",",$line);
		my ($logs,$k,$thr) = (@items);
                $logs =~ s/<(.*?)>/strftime("$1", localtime)/ge;
                foreach my $log (glob($logs)){
                        print "$log,$k,$thr\n";
			checkfile($log,$k,$thr);	
                }
	}		
	close CNF;
}

sub checkfile{
my ($logfile,$key,$threshold) = @_;
my $errcnt = 0;
my $reserver;
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
	chomp $line;
	if($line =~ /$key/){
		push @$reserver, $line;
		$errcnt++;	
		scalar(@$reserver) > 5 and shift @$reserver;
	}
}
$curpos = tell(LOG);
close LOG;
if($errcnt > $threshold){
	open(TMP,">$tmp") or die "can't open file $tmp !";
	print TMP $curpos;
	close TMP;
        print "exception over $threshold times\n";
        my $content = join "\n", @$reserver;
	alertlog($logfile,$key,$errcnt,$content);
}
}
sub alertlog{
	my ($logfile,$key,$errcnt,$err) = @_;	
	my $subject = "商盟server$server_ip日志异常";
	$err = "日志路径:$logfile\n错误日志如下：\n".$err;
	open (LOG,">>$log") || die "can't open file $log $!";
	print LOG "$logfile has $key over $errcnt times!\n"; 
	close LOG;
	sendmail(subject=>$subject,mailto=>$mailto,content=>$err);

}
