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

use Test::More tests => 5;
use PPI       ();
use Perl::SAX ();

use vars qw{$TESTDIR};
BEGIN {
	$TESTDIR = 't.data';
}

# Create a new, default, object
my $Driver = Perl::SAX->new;
isa_ok( $Driver, 'Perl::SAX' );

# Load the test document
my $Document = PPI::Document->load( catfile($TESTDIR, '01_tiny.perl') );
isa_ok( $Document, 'PPI::Document' );

# Do the parsing
ok( $Driver->parse( $Document ), '->parse returns true' );

# Get the results
my $Output = $Driver->{Output};
ok( ref $Output eq 'SCALAR', 'SCALAR output found' );
is( length $$Output, 459, 'Output is the correct length' );

exit(0);
