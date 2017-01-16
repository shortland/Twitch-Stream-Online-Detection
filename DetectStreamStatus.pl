#!/usr/bin/perl

use CGI;
use JSON qw( decode_json );

$client_id = YOUR_TWITCH_AUTH_ID;

BEGIN {
	$cgi = new CGI;
	$username = $cgi->param("username");
}

print $cgi->header(-type => "text/html");

sub getUserID {
	my ($username) = @_;
	my $res = `curl -H 'Accept: application/vnd.twitchtv.v5+json' -H 'Client-ID: $client_id' -X GET https://api.twitch.tv/kraken/users?login=$username`;
	my $decoded = decode_json($res);
	my $userID = $decoded->{'users'}[0]{'_id'} . "\n";
	return $userID;
}

sub getGamePlaying {
	my ($userID) = @_;
	my $res = `curl -H 'Accept: application/vnd.twitchtv.v5+json' -H 'Client-ID: $client_id' -X GET https://api.twitch.tv/kraken/streams/$userID`; 
	$res =~ s/null/"null"/g;
	my $decoded = decode_json($res);
	my $isLive = $decoded ->{'stream'};
	my $game = $decoded ->{'stream'}{'game'};
	
	if($isLive =~ /^(null)$/) {
		return -1;
	}
	else {
		return $game;
	}
}

$gamePlaying = getGamePlaying(getUserID($username));

if($gamePlaying =~ /^(-1)$/) {
	print "Stream offline";
}
else {
	print $username . " playing " . $gamePlaying;
}


open(STDERR, ">&STDOUT");