#!/usr/bin/perl
use Net::SMTP;
use MIME::Base64;
use warnings;
use strict;

my $mailserver = 'mail.c-platform.com';
my $boundary = 'wenqi';
my $username='jsmobileservice@c-platform.com';
my $password='cplatform';
my $from_mail='jsmobileservice@c-platform.com';
my $smtp;
my @mail_to = ('wenqi@c-platform.com','cncruyff@gmail.com');
my $subject = "test";
my $content = "Test From You";
my @attatchs = ();
#&sendmail(subject=>'²âÊÔ',mailto=>'wenqi@c-platform.com,cncruyff@gmail.com',content=>'ÕâÊÇ²âÊÔ');
sub sendmail{
	my %opts = @_;
	if($opts{"subject"}){
		$subject = $opts{"subject"};
	}
	if($opts{"mailto"}){
		@mail_to = split ',',$opts{"mailto"};
	}
	if($opts{"content"}){
		$content = $opts{"content"};
		print $content;
	}	
	if($opts{"attatchs"}){
		@attatchs = split ',',$opts{"attatchs"};
	}

	do_send();
}
sub do_send{
	login();
	title();
	body();
}
sub login{
	$smtp = Net::SMTP->new("$mailserver", Hello=>'wenqi', Timeout => 120, Debug => 0);
	$smtp->command('AUTH PLAIN')->response();
	my $userpass = encode_base64("\000$username\000$password");
	$userpass =~ s/\n//g;
	$smtp->command($userpass)->response();
}
sub title{
	$smtp->mail("$from_mail");
	my $to_string;
	for my $to_email(@mail_to)
	{
		$smtp->to($to_email);
		$to_string .= "$to_email,";
	}
	$smtp->data();
	$smtp->datasend("From: $from_mail\n");
	$smtp->datasend("To: $to_string\n");
	$smtp->datasend("Subject: $subject\n");
}
sub body{
	my $body = "MIME-Version: 1.0\n";
	$body .= "Content-type: multipart/mixed;\n\tboundary=".$boundary."\n";
	$body .= "\n";
	$body .= "--".$boundary."\n";
	$body .= "Content-type: text/plain\n";
	$body .= "Content-Disposition: quoted-printable\n";
	$body .= "\n$content\n";
	if(scalar @attatchs >0 ){
		for my $attatch (@attatchs){
			$body .= "--".$boundary."\n";
			$body .= "Content-Type: application/x; name=$attatch\n";
			$body .= "Content-Transfer-Encoding: base64\n";
			$body .= "Content-Disposition: attachment; filename=$attatch\n\n";
			my $encoder = encode_attach($attatch);
			$body .= "$encoder\n";
			print $attatch,"--afiel\n";
		}
		$body .= "--".$boundary."--\n";
	}
	$smtp->datasend("$body");
	$smtp->dataend();
	$smtp->quit;
}
sub encode_attach{
	my $a_file = shift(@_);
	my $re_encode;
	open my $fh,'<',"$a_file";
	binmode $fh;
	my $buffer;
	while(read($fh,$buffer,60*57)){
			$re_encode .= encode_base64($buffer);
	}
	close $fh;
	$re_encode;
}
1;
