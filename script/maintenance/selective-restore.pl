#!/usr/bin/perl

use strict;
use warnings;

my $output = 1;

while (<STDIN>) {
	if(/^-- Current Database: `([^`]+)`$/) {
		if($1 eq $ARGV[0]) {
			$output = 1;
		} else {
			$output = 0;
		}
	}
	
	if($output) {
		my $line = $_;

		if($ARGV[1] && ($line =~ /^USE `$ARGV[0]`;$/ || $line =~ /^CREATE DATABASE[^`]+`$ARGV[0]`/)) {
			$line =~ s/$ARGV[0]/$ARGV[1]/g;
		}

		print $line;
	}
}

