#!/usr/bin/perl -w

# Formal testing for Perl::SAX

# The main test file, which for now means making sure ->new creates an object

use strict;
use lib ();
use UNIVERSAL 'isa';
use File::Spec::Functions ':ALL';
BEGIN {
	$| = 1;
	unless ( $ENV{HARNESS_ACTIVE} ) {
		require FindBin;
		chdir ($FindBin::Bin = $FindBin::Bin); # Avoid a warning
		lib->import( catdir( updir(), updir(), 'modules') );
	}
}

use Test::More tests => 1;
use Perl::SAX ();

# Create a new, default, object
isa_ok( Perl::SAX->new, 'Perl::SAX' );

exit(0);
