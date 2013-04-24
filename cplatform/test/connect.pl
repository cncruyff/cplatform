#!/usr/bin/perl
use strict;
use warnings;
use DBI;

my $dsn = "DBI:mysql:host=localhost;database=duty";
my $dbh = DBI->connect ($dsn,"root","lmsh123")
		or die "Cannot connect to server\n";

print "Connected\n";
my $count = $dbh->do("insert into program_error_log (err_time,server_name,ip,program_name,log_path,log_content) values(unix_timestamp(),?,?,?,?,?)",undef,'database','192.168.5.174','test.jar','/tmp/log/1.log','error  test');
$dbh->disconnect();
print "Disconnected\n";
