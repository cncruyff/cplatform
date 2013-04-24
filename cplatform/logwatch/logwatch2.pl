#!/usr/bin/perl
use strict;
use warnings;
use POSIX qw(strftime);
use DBI;
require "../lib/mail.pl";
require "../lib/host.pl";
require "../lib/file.pl";


my $server_name = getHostName();
my $serverip = getHostIp();
my $log = "run.log";
my $mailto = 'wenqi@c-platform.com|xuxy@c-platform.com|sunyx@c-platform.com';
my $conf = "monitor.conf";
my $dsn = "DBI:mysql:host=localhost;database=duty";
my $subject = "商盟服务器$server_name $serverip日志异常";
my $dbh = DBI->connect ($dsn,"root","lmsh123")
                or die "Cannot connect to server\n";
print "Connected\n";

open(CNF,"$conf") || die "can't open file $conf $!";
my $options;
while(my $line = <CNF>){
        chomp $line;
        my @items = split(",",$line);
        my ($program,$logs,$k,$thr,$after,$mail) = (@items);
        $mail ||= $mailto;
        $logs =~ s/<(.*?)>/strftime("$1", localtime)/ge;
        foreach my $log (glob($logs)){
                print "$log,$k,$thr,$after,$mail\n";
                $options = {program=>"$program",logfile=>"$log",key=>$k,threshold=>$thr,after=>$after,alert=>\&action,mail=>$mail};
                checkfile($options);
        }
}
close CNF;
sub action{
        my $cont = shift;
        my $count = $dbh->do("insert into program_error_log (err_time,server_name,ip,program_name,log_path,log_content) values(unix_timestamp(),?,?,?,?,?)",undef,"$server_name","$serverip","$options->{program}","$options->{logfile}","$cont");
	
	my $logfile = $options->{logfile};
	open (LOG,">>$log") || die "can't open file $log $!";
	print LOG "$logfile has $options->{key} over $options->{threshold} times!\n"; 
	close LOG;

	my $err = "日志路径:$logfile\n错误日志如下：\n".$cont;
	my $mail = $options->{mail};
	$mail =~ s/\|/,/g;
	print $mail;
	sendmail(subject=>$subject,mailto=>$mail,content=>$err);
}
$dbh->disconnect();
print "Disconnected\n";

#{logfile=>"/opt/cplatform/logwatch/1.log",key=>"error",threshold=>2,after=>2,alert=>\&action}
