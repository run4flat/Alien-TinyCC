#!/usr/bin/perl
use strict;
use warnings;

# Assume good unless we find a problem
my $to_return = 0;

# Did I remember to touch the Changes file?
my $touched_files = `git status Changes --porcelain`;
if ($touched_files !~ /^M/) {
	# Assume bad unless the user overrides
	$to_return = 1;
	$|++;
	print "It looks like you didn't update the Changes file. Should I continue (y/n)? ";
	open STDIN, '<', '/dev/tty';
	my $response = <>;
	
	$to_return = 0 if $response =~ 'y';
}

exit($to_return);
